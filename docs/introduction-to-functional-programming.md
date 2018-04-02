# Introduction to *Functional Programming*

## First program

Open up your favorite editor and create another Elixir program:

```elixir
defmodule FizzBuzz do
  def up_to(n) do
    1..n
    |> Enum.to_list()
    |> iterate([])
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp transform(value) when rem(value, 15) == 0, do: "FizzBuzz"
  defp transform(value) when rem(value, 3) == 0, do: "Fizz"
  defp transform(value) when rem(value, 5) == 0, do: "Buzz"
  defp transform(value), do: value

  defp iterate([], acc) do
    acc
  end

  defp iterate([head | tail], acc) do
    iterate(tail, [ transform(head) | acc ])
  end
end

IO.puts(FizzBuzz.up_to(16))
```

We can compile and run our program in a single step using the `elixir` command:

```bash
$ elixir examples/fizzbuzz.exs
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
16
```

Let's analyze this example bit by bit.

## Variables and Immutability

Elixir is an immutable programming language. Any variables defined cannot be changed. While this imposes some design considerations, it is a vital part of Elixir's ability to write concurrent and robust applications. Variable assignment is referred to as *binding*, where a term is bound to a value. Here's a taste of some simple bindings:

Binding variables:

```elixir
iex> sum = 1 + 1
2
iex> names = ["alice", "bob", "ted"]
["alice", "bob", "ted"]
iex> [first | rest ] = names
["alice", "bob", "ted"]
iex> first
"alice"
iex> rest
["bob", "ted"]
```

While variables are immutable and can only be assigned once, Elixir allows us to rebind a variable to a new value. It is important to realize that this does *not* change the original variable. Any reference to the previous assignment maintains the original binding.

Rebinding Variables:

```elixir
iex> sum = 1 + 2
3
iex> initial_sum = fn -> IO.puts sum end
#Function<20.17052888 in :erl_eval.expr/5>

iex> sum = 3 + 4
7
iex> initial_sum.()
3
:ok
```

## Anonymous Functions

Along with variable binding, we just got our first taste of the anonymous function syntax. Anonymous functions can be defined with the `fn arg1, arg2 -> end` syntax and invoked with the explicit "dot notation." As you would expect from a functional language, functions in Elixir are first class citizens and can be passed around and invoked from other functions.

First Class Functions:

```elixir
iex> add = fn num1, num2 ->
...(1)>   num1 + num2
...(1)> end
#Function<12.17052888 in :erl_eval.expr/5>

iex> subtract = fn num1, num2 ->
...(2)>   num1 - num2
...(2)> end
#Function<12.17052888 in :erl_eval.expr/5>

iex> perform_calculation = fn num1, num2, func ->
...(3)>   func.(num1, num2)
...(3)> end
#Function<18.17052888 in :erl_eval.expr/5>

iex> add.(1, 2)
3
iex> perform_calculation.(5, 5, add)
10
iex> perform_calculation.(5, 5, subtract)
0
iex> perform_calculation.(5, 5, &(&1 * &2))
25
```

The last example shows Elixir's *shorthand function* syntax. The `&(&1 * &2)` is simply syntactic sugar for:

```elixir
iex> perform_calculation.(5, 5, fn a, b -> a * b end)
25
```

The shorthand function syntax is useful when performing simple operations on one or two operands:

```elixir
iex> Enum.map [3, 7, 9], &(&1 * 2)
[6, 14, 18]
iex> Enum.filter [1, "red", 2, "green"], &(is_number &1)
[1, 2]
```

### *Warning: Use sparingly*

> The shorthand syntax is nice and succinct, but it should be used only in cases when its meaning is obvious and your arguments few. Your code should strive for clarity over brevity, always.

## Captured Functions

The shorthand example also showcased the syntax for *capturing* functions. Capturing is used for functions defined within modules, or *named functions* (Covered in the next section), where a function reference is needed instead of invocation. Both name and arity are required for function identification when capturing.

Capturing named functions:
```elixir
iex> add = &Kernel.+/2
&Kernel.+/2
iex> add.(1,2)
3
iex> Enum.reduce [1, 2, 3], 0, &Kernel.+/2
6
```

When performing `1 + 2`, underneath Elixir is calling the named function `+`, defined and imported automatically from the `Kernel` module. Modules are the main building blocks of Elixir programs.

## Named Functions

Named functions are functions defined within Modules. Named functions are similar to anonymous functions but the dot notation is not required for invocation.

```elixir
iex>

defmodule Weather do
  def celsius_to_fahrenheit(celsius) do
    (celsius * 1.8) + 32
  end

  def high, do: 50
  def low, do: 32
end

{:module, Weather, ...
iex> Weather.high
50
iex> Weather.celsius_to_fahrenheit(20)
68.0
```

We'll be covering modules extensively in the next section.

## Pattern Matching

Pattern matching lives at the heart of the Erlang Virtual Machine. When binding or invoking a function, the VM is pattern matching on the provided expression. For example, when Elixir binds a variable on the left hand side of `=` with the expression on the right, it always does so via pattern matching.

```elixir
iex> a = 1
1
iex> 1 = a
1
iex> b = 2
2
iex> ^a = b
** (MatchError) no match of right hand side value: 2
iex> ^a = 1
1
iex> [first, 2, last] = [1, 2, 3]
[1, 2, 3]
iex> first
1
iex> last
3
```

`^a = b` shows the syntax for pattern matching against a variable's value instead of performing assignment. Pattern matching is used throughout Elixir programs for destructuring assignment, control flow, function invocation, and simple failure modes where a program is expected to crash unless a specific pattern is returned.

## Pipeline Operator

One of the most simple, yet effective features in Elixir is the *pipeline operator*. The pipeline operator solves the issue many functional languages face when composing a series of transformations where the output from one function needs passed as the input to another. This requires solutions to be read in reverse to understand the actions being performed, hampering readability and obscuring the true intent of the code. Elixir elegantly solves this problem by allowing the output of a function to be *piped* as the first parameter to the input of another. At compile time, the functional hierarchy is transformed into the nested, "backward" variant that would otherwise be required.

```elixir
iex> "Hello" |> IO.puts
Hello
:ok
iex> [3, 6, 9] |> Enum.map(fn x -> x * 2 end) |> Enum.at(2)
18
```

To grasp the full utility the pipeline provides, consider a module that fetches new messages from an API and saves the results to a database. The sequence of steps would be:

- Find the account by authorized user token
- Fetch new messages from API with authorized account
- Convert JSON response to keyword list of messages
- Save all new messages to the database

Without pipeline:

```elixir
defmodule MessageService do
  ...
  def import_new_messages(user_token) do
    Enum.each(
      parse_json_to_message_list(
        fetch(find_user_by_token(user_token), "/messages/unread")
    ), &save_message(&1))
  end
  ...
end
```

Proper naming and indentation help the readability of the previous block, but its intent is not immediately obvious without first taking a moment to decompose the steps from the inside out to grasp an understanding of the data flow.

Now consider this series of steps with the pipeline operator:

```elixir
defmodule MessageService do
  ...
  def import_new_messages(user_token) do
    user_token
    |> find_user_by_token
    |> fetch("/messages/unread")
    |> parse_json_to_message_list
    |> Enum.each(&save_message(&1))
  end
  ...
end
```

Piping the result of each step as the first argument to the next allows allows programs to be written as a series of transformations that any reader would immediately be able to read and comprehend without expending extra effort to unwrap the functions, as in the first solution.

The Elixir standard library focuses on placing the subject of the function as the first argument, aiding and encouraging the natural use of pipelines.

## Assignments

### Introduction

- [String](https://hexdocs.pm/elixir/String.html) module documentation.
- What is [geohashing](http://www.bigfastblog.com/geohash-intro)?

### First Task

```bash
$ git checkout TASK_FP_1
```

### Second Task

```bash
$ git checkout TASK_FP_2
```

### Cleanup

```bash
$ git reset .
$ git checkout .
$ git checkout master
```
