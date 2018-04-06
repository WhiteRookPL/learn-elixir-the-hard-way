# Introduction to *Elixir* programming language

## Modules

Modules are the main building blocks of Elixir programs. Modules can contain named functions, import functions from other modules, and use macros for powerful composition techniques.

### First program

Open up your favorite editor and create your first Elixir program:

```elixir
defmodule Rocket do
  def start_launch_sequence do
    seconds = 10

    IO.puts "T - #{seconds}..."
    countdown(seconds)
  end

  defp countdown(seconds) do
    for i <- seconds - 1 .. 1 do
      IO.puts "#{i}..."
    end
    blastoff()
  end

  defp blastoff do
    IO.puts "Liftoff!"
  end
end

Rocket.start_launch_sequence()
```

We can compile and run our program in a single step using the `elixir` command:

```bash
$ elixir examples/rocket.exs
T - 10...
9...
8...
7...
6...
5...
4...
3...
2...
1...
Liftoff!
```

Let's analyze this example bit by bit.

### Elixir files

> Elixir files are named `.exs`, which stands for Elixir script, and `.ex`
> are typically compiled to Erlang BEAM byte-code. For simple one off programs,
> sys-admin scripts etc. use `.exs`.

You can also fire up `iex` in the same directory and use the `c` helper function

```elixir
iex> c "examples/rocket.exs"
T - 10...
...
```

Publicly reachable functions are defined with the `def` keyword, while private functions use `defp`. It is common with Elixir code to group public functions with their private counterparts instead of lumping all public and private functions as separate groups in the source file. Attempting to call a `defp` function will result in an error:

```elixir
iex> Rocket.countdown(1)
** (UndefinedFunctionError) undefined function: Rocket.countdown/1
    Rocket.countdown(1)
```

## Alias, Import, Require

A few keywords exist in Elixir that live at the heart of module composition:

* `alias` used to register aliases for modules
* `import` imports functions and macros from other modules
* `require` ensures modules are compiled and loaded so that macros can be invoked

In the example below `:math` refers to the Erlang math module and makes
it accessible as `Math` (following the Elixir naming convention for
Modules).

Furthermore, we could have imported the entire Math module with `import
Math`; however, since we only wish to call the `pi` function, we've limited the
import to only that specific function.

```elixir
defmodule Converter do
  alias :math, as: Math
  import Math, only: [pi: 0]

  def degrees_to_radians(degrees) do
    degrees * (pi / 180)
  end

  def sin_to_cos(x) do
    Math.cos(x - (pi/2))
  end
end
{:module, Converter...

iex> Converter.degrees_to_radians(90)
1.5707963267948966

iex> Converter.sin_to_cos(120)
0.5806111842123187
```

Rather than calling `cos` via the Math module, we could have imported it
as well

```elixir
  import Math, only: [pi: 0, cos: 1]

  def sin_to_cos(x) do
    cos(x - (pi/2))
  end
```

## Getting Started

The easiest way to get started is firing up `iex`, or *Interactive Elixir*, to experiment with code live in the Elixir shell. The code examples in this chapter were entered directly in `iex` and you are encouraged to follow along in your own session.

### Terminology

- *term* - An element of any data type and is commonly referred to as such in documentation and code examples
- *literal* - A value within source code representing a type
- *bitstring* - Used to store an area of untyped memory
- *binary* - Bitstrings containing a number of bits evenly divisible by eight and commonly used to store UTF-8 encoded strings
- *arity* - The number of arguments a function accepts

### Everything is an expression

```elixir
iex> result = if 1 == 1 do
...(1)>   "correct"
...(1)> else
...(1)>   "incorrect"
...(1)> end
"correct"
iex> result
"correct"
```

### Immutability

Variables are immutable. Once assigned, they cannot be changed. Instead of operating on information hiding and mutating shared state, Elixir programs are constructed around data transformation and message passing among isolated processes. This follows the [*Actor Model*](http://en.wikipedia.org/wiki/Actor_model) of concurrency.

### Parenthesis are optional

Parenthesis are optional as long as their absence does not introduce ambiguity.

### Documentation is first class

Documentation in Elixir is written in [Markdown](http://en.wikipedia.org/wiki/Markdown) and compiled into the program as metadata. This allows formatted documentation to be brought up on-demand through `iex`.

Additional thing that is very convenient is `doctest`. You can write tests inside your comments above function definition (similar feature is available in *Python*).

Example for such is [here](../apps/air_quality/lib/utilities/geohash.ex) and here are [tests](../apps/air_quality/test/geohash_test.exs).

### Coexistence with the Erlang ecosystem

Elixir programs compile to the Erlang Abstract Format, or byte-code for Erlang's BEAM Virtual Machine. Erlang modules can be called from Elixir and vice-versa. Calling Erlang modules from Elixir simply requires using an *atom* by prefixing the module name with a semicolon.

```elixir
iex> IO.puts "Print from Elixir"
Print from Elixir
:ok
iex> :io.fwrite "Print from Erlang~n"
Print from Erlang
:ok
iex> :math.pi
3.141592653589793
iex> :erlang.time
{19, 41, 20}
```

## Building Blocks

### Types

Elixir is dynamically typed and contains a small, but powerful set of types including:

- Integer
- Float
- Atom
- Tuple
- List
- Bitstring
- Pid

#### Atoms

*Atoms* are constants with a name and synonymous with symbols in languages such as Ruby. Atoms are prefixed by a semicolon, such as `:ok` and are a fundamental utility in Elixir. Atoms are used for powerful *pattern matching* techniques, as well as a simple, yet effective way to describe data and return values. Internally, Elixir programs are represented by an AST (Abstract Syntax Tree) comprised of atoms and metadata.

```elixir
iex> is_atom :ok
true
```

#### Tuples

*Tuples* are arrays of fixed length, stored contiguously in memory, which can hold any combination of Elixir types. Unlike Erlang, tuples in Elixir are indexed starting at zero.

```elixir
iex> ids = {1, 2, 3}
{1, 2, 3}
iex> is_tuple ids
true
iex> elem ids, 0
1
iex> elem ids, 1
2
```

#### Lists

*Lists* are linked-lists containing a variable number of terms. Like tuples, lists can hold any combination of types. Element lookup is `O(N)`, but like most functional languages, composing lists as a head and tail is highly optimized. The `head` of the list is the first element, with the `tail` containing the remaining set. This syntax is denoted by `[h|t]` and can be used to show a list entirely as a series of linked lists. For example:

```elixir
iex> list = [1, 2 ,3]
[1, 2, 3]
iex> [ 1 | [2, 3] ] == list
true
iex> [1 | [2 | [3]] ] == list
true
iex> hd list
1
iex> tl list
[2, 3]
iex> [head|tail] = list
[1, 2, 3]
iex> head
1
iex> tail
[2, 3]
iex> h Enum.at

      def at(collection, n, default // nil)

Finds the element at the given index (zero-based).
Returns default if index is out of bounds.

Examples

┃ iex> Enum.at([2, 4, 6], 0)
┃ 2
┃ iex> Enum.at([2, 4, 6], 2)
┃ 6
┃ iex> Enum.at([2, 4, 6], 4)
┃ nil
┃ iex> Enum.at([2, 4, 6], 4, :none)
┃ :none

iex> Enum.at list, 2
3
iex> Enum.reverse list
[3, 2, 1]
```

##### `iex` "h" *helper function*

> Use `h` followed by a Module name or Module function name to call up markdown formatted documentation as seen in the ninth iex entry of the previous example.

#### Keyword Lists

*Keyword Lists* provide syntactic sugar for using a list to represent a series of key-value pairs. Internally, the key-value pairs are simply a list of tuples containing two terms, an atom and value. Keyword lists are convenient for small sets of data where true hash or map based lookup performance is not a concern.

```elixir
iex> types = [atom: "Atom", tuple: "Tuple"]
[atom: "Atom", tuple: "Tuple"]
iex> types[:atom]
"Atom"
iex> types[:not_exists]
nil
iex> types == [{:atom, "Atom"}, {:tuple, "Tuple"}]
true

iex> IO.inspect types
[atom: "Atom", tuple: "Tuple"]

iex> IO.inspect types, raw: true
[{:atom, "Atom"}, {:tuple, "Tuple"}]

iex> Keyword.keys(types)
[:atom, :tuple]
iex> Keyword.values types
["Atom", "Tuple"]

iex> Keyword.
delete/2          delete_first/2    drop/2            equal?/2
fetch!/2          fetch/2           from_enum/1       get/3
get_values/2      has_key?/2        keys/1            keyword?/1
merge/2           merge/3           new/0             new/1
new/2             pop/3             pop_first/3       put/3
put_new/3         split/2           take/2            update!/3
update/4          values/1
```

##### *tab-completion* in `iex`

> Gratuitous use helps discover new functions and explore module APIs

#### Maps & Structs

Maps are key/value stores and synonymous with hashes or dictionaries in other languages. Maps support powerful pattern matching and upsert operations and are defined with the `%{}` syntax.

```elixir
iex> map = %{name: "elixir", age: 3, parent: "erlang"}
%{age: 3, name: "elixir", parent: "erlang"}

iex> map_with_strings = %{"name" => "elixir", "age" => 3, "parent" => "erlang"}
%{"age" => 3, "name" => "elixir", "parent" => "erlang"}

iex> map_with_strings["name"]
"elixir"

iex> map_with_strings[:name]
nil

iex> %{name: name} = map
%{age: 3, name: "elixir", parent: "erlang"}

iex> %{age: age} = map
%{age: 3, name: "elixir", parent: "erlang"}

iex> age
3

iex> map = %{map | age: 4}
%{age: 4, name: "elixir", parent: "erlang"}

iex> map = %{map | age: 4, new_key: "new val"}
** (ArgumentError) argument error
    (stdlib) :maps.update(:new_key, "new val", %{age: 4, name: "elixir", parent: "erlang"})
```

Structs are tagged maps used for polymorphic dispatch and pattern matching.

```elixir
iex>
defmodule Tweet do
  defstruct id: nil, text: "", username: nil, hash_tags: [], mentions: []
end

iex> status = %Tweet{text: "Chirp!"}
%Tweet{id: nil, text: "Chirp!", username: nil, hash_tags: [],
 mentions: []}

iex> status.text
"Chirp!"

iex> status = %Tweet{status | text: "RT Chirp!"}
%Tweet{id: nil, text: "RT Chirp!", username: nil, hash_tags: [],
 mentions: []}

iex> status.text
"RT Chirp!"

iex> %Tweet{status | text: "@elixir-lang rocks!", username: "afronski"}
Tweet{id: nil, text: "@elixir-lang rocks!", username: "afronski",
 hash_tags: [], mentions: []}
```

## Control Flow

### Truth

Only `false` and `nil` are coerced to `false`. All other values are considered are coerced to `true`.

### `if` / `unless`

Elixir supports the traditional `if` and `unless` keywords for control flow branching, but as we'll see, their use will be limited in favor of superior approaches.

```elixir
iex> saved = true
true
iex> if saved, do: IO.puts("saved"), else: IO.puts("failed")
saved
:ok

iex> if saved do
...(3)>   IO.puts "saved"
...(3)> else
...(3)>   IO.puts "failed"
...(3)> end
saved
:ok

iex> unless saved do
...(4)>   IO.puts "save failed"
...(4)> end
nil
```

The first two `if` examples demonstrate Elixir's inline and expanded expression syntax. In fact, the expanded, multi-line example is simply sugar for the the inline `do:` / `else:` syntax.

### cond

For cases where nesting or chaining ifs would be required, `cond` can be used instead to list multiple expressions and evaluate the first true match.

```elixir
iex> temperature = 30
30
iex> cond do
...(2)>   temperature >= 212 -> "boiling"
...(2)>   temperature <= 32 -> "freezing"
...(2)>   temperature <= -459.67 -> "absolute zero"
...(2)> end
"freezing"
```

### case

`case` provides control flow based on pattern matching. Given an expression, case will match against each clause until the first pattern is matched. At least one pattern must be matched or `CaseClauseError` will be raised. Let's write a mini calculation parser to perform a few basic operations:

```elixir
iex>
calculate = fn expression ->
  case expression do
    {:+, num1, num2} -> num1 + num2
    {:-, num1, num2} -> num1 - num2
    {:*, num1, 0}    -> 0
    {:*, num1, num2} -> num1 * num2
    {:/, num1, num2} -> num1 / num2
  end
end
#Function<6.17052888 in :erl_eval.expr/5>

iex> calculate.({:+, 8, 2})
10
iex> calculate.({:*, 8, 0})
0
iex> calculate.({:*, 8, 2})
16
iex> calculate.({:^, 8, 2})
** (CaseClauseError) no case clause matching: {:^, 8, 2}
iex>
```

The `calculate` function accepts a three element tuple containing an atom to represent the operation to perform followed by two numbers. `case` is used to pattern match  against the operation, as well as bind the the `num1` and `num2` variables for the matched clause.

An underscore in a match can serve as a "catch-all" clause:

```elixir
iex>

calculate = fn expression ->
  case expression do
    {:+, num1, num2} -> num1 + num2
    {:-, num1, num2} -> num1 - num2
    {:*, num1, num2} -> num1 * num2
    _ -> raise "Unable to parse #{inspect expression}"
  end
end
#Function<6.17052888 in :erl_eval.expr/5>

iex> calculate.({:/, 10, 2})
** (RuntimeError) Unable to parse {:/, 10, 2}
```

### Guard clauses

*Guard Clauses* can be used to restrict a pattern from matching based on a condition or set of conditions. Consider an extension to our calculation parser where dividing by zero should never occur:

```elixir
iex>
calculate = fn expression ->
  case expression do
    {:+, num1, num2} -> num1 + num2
    {:-, num1, num2} -> num1 - num2
    {:*, num1, num2} -> num1 * num2
    {:/, num1, num2} when num2 != 0 -> num1 / num2
  end
end
#Function<6.17052888 in :erl_eval.expr/5>

iex> calculate.({:/, 10, 2})
5.0
iex> calculate.({:/, 10, 0})
** (CaseClauseError) no case clause matching: {:/, 10, 0}
```

The Virtual Machine supports a limited set of guard expressions:

- Comparison, boolean, and arithmetic operators:
  - `==`, `!=`, `===`, `!==`, `>`, `<`, `<=`, `>=`
  - `and`, `or`, `not`, `!`
  - `+`, `-`, `*`, `/`
  - Examples:
    - `def credit(balance, amt) when amt > 0`
    - `def debit(balance, amt) when amt > 0 and balance >= amt`
- Concatenation operators, providing the first term is a literal:
  - `<>`, `++`
- The `in` operator:
  - examples
    - `def grade(letter) when letter in ["A", "B"]`
- Type checking functions:
  - `is_atom/1`
  - `is_binary/1`
  - `is_bitstring/1`
  - `is_boolean/1`
  - `is_exception/1`
  - `is_float/1`
  - `is_function/1`
  - `is_function/2`
  - `is_integer/1`
  - `is_list/1`
  - `is_number/1`
  - `is_pid/1`
  - `is_port/1`
  - `is_record/1`
  - `is_record/2`
  - `is_reference/1`
  - `is_tuple/1`
- Top-level functions:
  - `abs`
  - `bit_size`
  - `byte_size`
  - `div`
  - `elem`
  - `float`
  - `hd`
  - `length`
  - `node`
  - `node`
  - `rem`
  - `round`
  - `self`
  - `size`
  - `tl`
  - `trunc`
  - `tuple_size`

## UTF-8 and Unicode

A string is a UTF-8 encoded binary. In order to understand exactly what we mean by that, we need to understand the difference between bytes and code points.

The Unicode standard assigns code points to many of the characters we know. For example, the letter `a` has code point `97` while the letter `ł` has code point `322`. When writing the string `"hełło"` to disk, we need to convert this sequence of characters to bytes. If we adopted a rule that said one byte represents one code point, we wouldn't be able to write `"hełło"`, because it uses the code point `322` for `ł`, and one byte can only represent a number from `0` to `255`. But of course, given you can actually read `"hełło"` on your screen, it must be represented *somehow*. That's where encodings come in.

When representing code points in bytes, we need to encode them somehow. Elixir chose the UTF-8 encoding as its main and default encoding. When we say a string is a UTF-8 encoded binary, we mean a string is a bunch of bytes organized in a way to represent certain code points, as specified by the UTF-8 encoding.

Since we have characters like `ł` assigned to the code point `322`, we actually need more than one byte to represent them. That's why we see a difference when we calculate the `byte_size/1` of a string compared to its `String.length/1`:

```elixir
iex> string = "hełło"
"hełło"
iex> byte_size(string)
7
iex> String.length(string)
5
```

There, `byte_size/1` counts the underlying raw bytes, and `String.length/1` counts characters.

> Note: if you are running on Windows, there is a chance your terminal does not use UTF-8 by default. You can change the encoding of your current session by running `chcp 65001` before entering `iex` (`iex.bat`).

UTF-8 requires one byte to represent the characters `h`, `e`, and `o`, but two bytes to represent `ł`. In Elixir, you can get a character's code point by using `?`:

```elixir
iex> ?a
97
iex> ?ł
322
```

You can also use the functions in [the `String` module](https://hexdocs.pm/elixir/String.html) to split a string in its individual characters, each one as a string of length 1:

```elixir
iex> String.codepoints("hełło")
["h", "e", "ł", "ł", "o"]
```

You will see that Elixir has excellent support for working with strings. It also supports many of the Unicode operations. In fact, Elixir passes all the tests showcased in the article ["The string type is broken"](http://mortoray.com/2013/11/27/the-string-type-is-broken/).

However, strings are just part of the story. If a string is a binary, and we have used the `is_binary/1` function, Elixir must have an underlying type empowering strings. And it does! Let's talk about binaries.

## Binaries (and bitstrings)

In Elixir, you can define a binary using `<<>>`:

```elixir
iex> <<0, 1, 2, 3>>
<<0, 1, 2, 3>>
iex> byte_size(<<0, 1, 2, 3>>)
4
```

A binary is a sequence of bytes. Those bytes can be organized in any way, even in a sequence that does not make them a valid string:

```elixir
iex> String.valid?(<<239, 191, 19>>)
false
```

The string concatenation operation is actually a binary concatenation operator:

```elixir
iex> <<0, 1>> <> <<2, 3>>
<<0, 1, 2, 3>>
```

A common trick in Elixir is to concatenate the null byte `<<0>>` to a string to see its inner binary representation:

```elixir
iex> "hełło" <> <<0>>
<<104, 101, 197, 130, 197, 130, 111, 0>>
```

Each number given to a binary is meant to represent a byte and therefore must go up to 255. Binaries allow modifiers to be given to store numbers bigger than 255 or to convert a code point to its UTF-8 representation:

```elixir
iex> <<255>>
<<255>>
iex> <<256>> # truncated
<<0>>
iex> <<256 :: size(16)>> # use 16 bits (2 bytes) to store the number
<<1, 0>>
iex> <<256 :: utf8>> # the number is a code point
"Ā"
iex> <<256 :: utf8, 0>>
<<196, 128, 0>>
```

If a byte has 8 bits, what happens if we pass a size of 1 bit?

```elixir
iex> <<1 :: size(1)>>
<<1::size(1)>>
iex> <<2 :: size(1)>> # truncated
<<0::size(1)>>
iex> is_binary(<<1 :: size(1)>>)
false
iex> is_bitstring(<<1 :: size(1)>>)
true
iex> bit_size(<< 1 :: size(1)>>)
1
```

The value is no longer a binary, but a bitstring -- a bunch of bits! So a binary is a bitstring where the number of bits is divisible by 8.

```elixir
iex>  is_binary(<<1 :: size(16)>>)
true
iex>  is_binary(<<1 :: size(15)>>)
false
```

We can also pattern match on binaries / bitstrings:

```elixir
iex> <<0, 1, x>> = <<0, 1, 2>>
<<0, 1, 2>>
iex> x
2
iex> <<0, 1, x>> = <<0, 1, 2, 3>>
** (MatchError) no match of right hand side value: <<0, 1, 2, 3>>
```

Note each entry in the binary pattern is expected to match exactly 8 bits. If we want to match on a binary of unknown size, it is possible by using the binary modifier at the end of the pattern:

```elixir
iex> <<0, 1, x :: binary>> = <<0, 1, 2, 3>>
<<0, 1, 2, 3>>
iex> x
<<2, 3>>
```

Similar results can be achieved with the string concatenation operator `<>`:

```elixir
iex> "he" <> rest = "hello"
"hello"
iex> rest
"llo"
```

A complete reference about the binary / bitstring constructor `<<>>` can be found [in the Elixir documentation](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#%3C%3C%3E%3E/1). This concludes our tour of bitstrings, binaries and strings. A string is a UTF-8 encoded binary and a binary is a bitstring where the number of bits is divisible by 8. Although this shows the flexibility Elixir provides for working with bits and bytes, 99% of the time you will be working with binaries and using the `is_binary/1` and `byte_size/1` functions.

## Charlists

A charlist is nothing more than a list of code points. Char lists may be created with single-quoted literals:

```elixir
iex> 'hełło'
[104, 101, 322, 322, 111]
iex> is_list 'hełło'
true
iex> 'hello'
'hello'
iex> List.first('hello')
104
```

You can see that, instead of containing bytes, a charlist contains the code points of the characters between single-quotes (note that by default IEx will only output code points if any of the integers is outside the ASCII range). So while double-quotes represent a string (i.e. a binary), single-quotes represent a charlist (i.e. a list).

In practice, charlists are used mostly when interfacing with Erlang, in particular old libraries that do not accept binaries as arguments. You can convert a charlist to a string and back by using the `to_string/1` and `to_charlist/1` functions:

```elixir
iex> to_charlist "hełło"
[104, 101, 322, 322, 111]
iex> to_string 'hełło'
"hełło"
iex> to_string :hello
"hello"
iex> to_string 1
"1"
```

Note that those functions are polymorphic. They not only convert charlists to strings, but also integers to strings, atoms to strings, and so on.

## Assignments

### Introduction

Our application is a very simple *HTTP API* that returns air quality metrics and current weather conditions for a given location inside a *JSON* object. Air quality metrics are fetched from two independent services - *GIOŚ* and *Airly*. For weather we are using *Yahoo Weather API*.

Of course in order to avoid violating the terms of services and rate limits our *API* employs additional caching layer and small offline preprocessing jobs.

- [String](https://hexdocs.pm/elixir/String.html) module documentation.
- What is [geohashing](http://www.bigfastblog.com/geohash-intro)?

### First Task

```bash
$ git checkout TASK_EX_1
```

### Second Task

```bash
$ git checkout TASK_EX_2
```

### Cleanup

```bash
$ git reset .
$ git checkout .
$ git checkout master
```
