defmodule AirQuality.Cache do
  @moduledoc """
  A simple ETS based cache for our external calls.
  """

  @doc """
  Retrieve a cached value or `nil` when *TTL* expired.
  """
  def get(table, key) do
    case :ets.lookup(table, key) do
      [value | _] -> check_freshness(value)
      [] -> nil
    end
  end

  defp check_freshness({_, value, expiration}) do
    cond do
      expiration > :os.system_time(:seconds) -> value
      :else -> nil
    end
  end

  @doc """
  Set cached value and returning it.
  """
  def set(table, key, value, ttl) when ttl >= 0 do
    expiration = :os.system_time(:seconds) + ttl
    :ets.insert(table, {key, value, expiration})

    value
  end
end
