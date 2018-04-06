defmodule AirQuality.Cache.CacheServer do
  @moduledoc """
  Server which represents cache API and handles ETS table creation.
  """

  use GenServer

  ### Client API

  @doc """
  Starts the cache server.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the cache item under `key`.

  Returns `{:ok, value}` if the item exists, `:error` otherwise.
  """
  def lookup(server, key) do
    # ???
    GenServer.call(server, nil)
  end

  @doc """
  Saves up the cache item with content equals `value` under `key`.

  Returns `:ok` if item was saved, `:error` otherwise.
  """
  def cache(server, key, value) do
    # ???
    GenServer.call(server, nil)
  end

  ### Behavior Callbacks

  @doc """
  Initializes the server state.
  """
  def init(:ok) do
    {:ok, :ets.new(__MODULE__, [:private, :set])}
  end

  @doc """
  Handles incoming synchronous calls to the server.

  We support two different calls:

  - {:lookup, key} - for getting value under given `key`,
  - {:cache, key, value} - for saving content passed as `value` under given `key`.
  """
  def handle_call({:lookup, key}, _from, table) do
    result = case AirQuality.Cache.get(table, key) do
      nil   -> :error
      value -> {:ok, value}
    end

    # ???
    {:reply, nil, nil}
  end

  def handle_call({:cache, key, value}, _from, table) do
    ttl = Application.get_env(:air_quality, :cache)[:ttl_in_seconds]
    ^value = AirQuality.Cache.set(table, key, value, ttl)

    # ???
    {:reply, nil, nil}
  end
end
