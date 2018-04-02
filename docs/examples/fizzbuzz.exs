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
