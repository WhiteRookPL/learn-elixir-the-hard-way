defmodule AirQuality.Cache.CacheServerTest do
  use ExUnit.Case

  @moduletag marked: true

  setup context do
    {:ok, pid} = AirQuality.Cache.CacheServer.start_link(name: context.test)

    {:ok, %{sever: pid}}
  end

  test "Item should be successfully cached via server", %{sever: pid} do
    key = "unique_key"
    value = 42

    AirQuality.Cache.CacheServer.cache(pid, key, value)

    assert AirQuality.Cache.CacheServer.lookup(pid, key) == {:ok, value}
  end

  test "After given TTL item should expire and server should return :error", %{sever: pid} do
    key = "unique_key"
    value = 42

    AirQuality.Cache.CacheServer.cache(pid, key, value)
    :timer.sleep(1000)

    assert AirQuality.Cache.CacheServer.lookup(pid, key) == :error
  end
end
