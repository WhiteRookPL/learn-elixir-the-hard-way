# Concurrency and Actor Model

## Processes

Elixir processes are fast and lightweight units of concurrency. Not to be confused with OS processes, millions of them can be spawned on a single machine, and each are managed entirely by the Erlang VM. Processes live at the core of Elixir application architectures and can send and receive messages to other processes located locally, or remotely on another connected Node.

### `spawn`

Spawn creates a new process and returns the Pid, or Process ID of the new process. Messages are sent to the processes using the `send/2` function.

### Mailboxes

Processes all contain a *mailbox* where messages are passively kept until consumed via a `receive` block. `receive` processes message in the order received and allows messages to be pattern matched. A common pattern is to send a message to a process with a tuple containing `self` as the first element. This allows the receiving process to have a reference to message's "sender" and respond back to the sender Pid with its own response messages.

```elixir
pid = spawn fn ->
  receive do
    {sender, :ping} ->
      IO.puts "Got ping"
      send sender, :pong
  end
end

send pid, {self, :ping}

# Got ping

receive do
  message -> IO.puts "Got #{message} back"
end

# Got pong back
```

`receive` blocks the current process until a message is received that matches a message clause. An `after` clause can optionally be provided to exit the receive loop if no messages are receive after a set amount of time.

```elixir
receive do
  message -> IO.inspect message
after 5000 ->
  IO.puts "Timeout, giving up"
end
```

Results in...

```elixir
# Timeout, giving up
```

### `spawn_link`

Similar to `spawn`, `spawn_link` creates a new process, but links the current and new process so that if one crashes, both processes terminate. Linking processes is essential to the Elixir and Erlang philosophy of letting programs crash instead of trying to rescue from errors. Since Elixir programs exist as a hierarchy of many processes, linking allows a predictable process dependency tree where failures in one process cascade down to all other dependent processes.

```elixir
pid = spawn_link fn ->
  receive do
    :boom -> raise "boom!"
  end
end

send pid, :boom
```

Results in...

```elixir
=ERROR REPORT==== 27-Dec-2013::16:49:14 ===
Error in process <...> with exit value: {{'Elixir.RuntimeError','__exception__',<<5 bytes>>},[{erlang,apply,2,[]}]}

** (EXIT from #PID<...>) {RuntimeError[message: "boom!"], [{:erlang, :apply, 2, []}]}
```

```elixir
pid = spawn fn ->
  receive do
    :boom -> raise "boom!"
  end
end

send pid, :boom
```

Results in...

```elixir
=ERROR REPORT==== 27-Dec-2013::16:49:50 ===
Error in process <0.71.0> with exit value: {{'Elixir.RuntimeError','__exception__',<<5 bytes>>},[{erlang,apply,2,[]}]}

iex>
```

The first example above using `spawn_link`, we see the process termination cascade to our own iex session from the `** (EXIT from #PID<...>)` error. Our iex session stays alive because it is internally restarted by a process Supervisor. Supervisors are covered in the next section on OTP.

## Holding state

Since Elixir is immutable, you may be wondering how state is held. Holding and mutating state can be performed by spawning a process that exposes its state via messages and infinitely recurses on itself with its current state. For example:

```elixir
defmodule Counter do
  def start(initial_count) do
    spawn fn -> listen(initial_count) end
  end

  def listen(count) do
    receive do
      :inc -> listen(count + 1)
      {sender, :val} ->
        send sender, count
        listen(count)
    end
  end
end
{:module, Counter,...

iex> counter_pid = Counter.start(10)
#PID<...>

iex> send counter_pid, :inc
:inc
iex> send counter_pid, :inc
:inc
iex> send counter_pid, :inc
:inc
iex> send counter_pid, {self, :val}
{#PID<...>, :val}

iex> receive do
...(13)>   value -> value
...(13)> end
13
```

## Registered processes

Pids can be registered under a name for easy lookup by other processes

```elixir
iex> pid = Counter.start 10
iex> Process.register pid, :count
true
iex> Process.whereis(:count) == pid
true
iex> send :count, :inc
:inc
iex> receive do
...(30)>   value -> value
...(30)> end
11
```

## Ugh, do I have to remember about all that stuff?

This application shows how to manage and hold state via "homegrown" processes and how OTP conventions have been
built up around these ideas.

While Elixir is immutable, state can be held in processes that continuously recurse on themselves. Processes can then accept messages from other processes to return or change their current state.

Example:

```elixir
defmodule Stack do
  def start(initial_stack) do
    spawn_link fn ->
      :global.register_name :custom_server, self
      listen initial_stack
    end
  end

  def listen(stack) do
    receive do
      {sender, :pop}         -> handle_pop(sender, stack)
      {sender, :push, value} -> listen([value|stack])
    end
  end

  def handle_pop(sender, []) do
    send sender, nil
    listen []
  end
  def handle_pop(sender, stack) do
    send sender, hd(stack)
    listen tl(stack)
  end
end

iex> {:ok, pid} = Stack.start([])
{:ok, ...}

iex> sender pid, {self(), :pop}
nil

iex> sender pid, {self(), :push, 7}

iex> sender pid, {self(), :pop}
7
```

"Starting" the custom stack server involves spawning a process that continually recurses on `listen` with the stack's current state. To push a value onto the stack, the process listens for a message containing the sender's pid, and a value `{sender, :push, value}` and then recurses back on itself with the value placed in the head of the stack. Similarly, to pop a value off the stack, the process listens for `{sender, :pop}` and sends the top of the stack as a message back to the sender, then recurses back on itself with the popped value removed.

Ugh, a lot of boilerplate, isn't it?

## There is hope! Enter the *OTP*

The OTP library brings tried and true conventions to holding state, process supervision, and message passing. For almost all cases where state needs to be held, it should be placed in an OTP generic server. Originally it is called `gen_server` in Erlang world, but Elixir has its own wrapper called `GenServer`.

It is a behavior module for implementing the server of a client-server relation.

A GenServer is a process like any other Elixir process and it can be used to keep state, execute code asynchronously and so on. The advantage of using a generic server process (GenServer) implemented using this module is that it will have a standard set of interface functions and include functionality for tracing and error reporting. It will also fit into a supervision tree.

The GenServer behavior abstracts the common client-server interaction. Developers are only required to implement the callbacks and functionality they are interested in.

Let's start with a code example and then explore the available callbacks. Imagine we want a GenServer that works like a stack, allowing us to push and pop items:

```elixir
defmodule Stack do
  use GenServer

  # Callbacks

  def handle_call(:pop, _from, [h | t]) do
    {:reply, h, t}
  end

  def handle_cast({:push, item}, state) do
    {:noreply, [item | state]}
  end
end

# Start the server:

iex> {:ok, pid} = GenServer.start_link(Stack, [:hello])

# This is the client:

iex> GenServer.call(pid, :pop)
:hello

iex> GenServer.cast(pid, {:push, :world})
:ok

iex> GenServer.call(pid, :pop)
:world
```

We start our Stack by calling start_link/3, passing the module with the server implementation and its initial argument (a list representing the stack containing the item :hello). We can primarily interact with the server by sending two types of messages. call messages expect a reply from the server (and are therefore synchronous) while cast messages do not.

Every time you do a GenServer.call/3, the client will send a message that must be handled by the handle_call/3 callback in the GenServer. A cast/2 message must be handled by handle_cast/2.

## What else is provided by *Erlang* runtime?

### *ETS* (Erlang Term Storage)

It is a in-memory key-value storage built into *Erlang VM*. *ETS* allows us to store any *Erlang* and *Elixir* term in an table. Working with ETS tables is done via Erlang's `:ets` module:

```elixir
iex> table = :ets.new(:buckets_registry, [:set, :protected])
#Reference<...>

iex> :ets.insert(table, {"foo", self()})
true

iex> :ets.lookup(table, "foo")
[{"foo", #PID<...>}]
```

When creating an ETS table, two arguments are required: the table name and a set of options. From the available options, we passed the table type and its access rules. We have chosen the `:set` type, which means that keys cannot be duplicated. We've also set the table's access to `:protected`, meaning only the process that created the table can write to it, but all processes can read from it. Those are actually the default values, so we will skip them from now on.

## Assignments

### First Task

```bash
$ git checkout TASK_AM_1
```

### Second Task

```bash
$ git checkout TASK_AM_2
```

### Cleanup

```bash
$ git reset .
$ git checkout .
$ git checkout master
```
