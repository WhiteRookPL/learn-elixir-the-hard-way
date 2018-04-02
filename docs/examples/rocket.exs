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
