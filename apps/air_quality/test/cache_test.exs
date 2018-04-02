defmodule AirQuality.Cache.CacheTest do
  use ExUnit.Case

  setup context do
    ets_id = :ets.new(context.test, [:private, :set])

    {:ok, %{table: ets_id}}
  end

  test "TTL lower than 0 does not make any sense", context do
    assert_raise FunctionClauseError, fn() ->
      key = "unique_key"
      value = 42

      AirQuality.Cache.set(context.table, key, value, -1)
    end
  end

  test "Item should be successfully cached when TTL is greater than 0", context do
    key = "unique_key"
    value = 42

    AirQuality.Cache.set(context.table, key, value, 5)

    assert AirQuality.Cache.get(context.table, key) == value
  end

  test "After given TTL item should expire and cache should return nil", context do
    key = "unique_key"
    value = 42

    AirQuality.Cache.set(context.table, key, value, 0)

    assert AirQuality.Cache.get(context.table, key) == nil
  end
end
