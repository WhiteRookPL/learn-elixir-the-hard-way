defmodule AirQuality.Cache.PreprocessedCacheServer do
  @moduledoc """
  Server which holds preprocessed data in memory.
  """

  use GenServer

  import AirQuality.Utilities.GeoHash, only: [is_geohash_inside_another_one?: 2]

  ### Client API

  @doc """
  Starts the preprocessed data cache server.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the city data based on `geohash`.

  Returns `{:ok, city}` if the item exists, `:error` otherwise.
  """
  def city(server, geohash) do
    GenServer.call(server, {:city_from, geohash})
  end

  @doc """
  Looks up the Airly station data name based on `geohash`.

  Returns `{:ok, station}` if the item exists, `:error` otherwise.
  """
  def airly_station(server, geohash) do
    GenServer.call(server, {:airly_station_from, geohash})
  end

  @doc """
  Looks up the GIOŚ station data name based on `geohash`.

  Returns `{:ok, station}` if the item exists, `:error` otherwise.
  """
  def gios_station(server, geohash) do
    GenServer.call(server, {:gios_station_from, geohash})
  end

  ### Behavior Callbacks

  @doc """
  Initializes the server state.
  """
  def init(:ok) do
    {:ok, cities} = AirQuality.Utilities.Preprocessing.process_cities

    {:ok, gios_stations} = AirQuality.Utilities.Preprocessing.process_stations("gios")
    {:ok, airly_stations} = AirQuality.Utilities.Preprocessing.process_stations("airly")

    {:ok, %{ cities: cities, gios: gios_stations, airly: airly_stations }}
  end

  @doc """
  Handles incoming synchronous calls to the server.

  We support three different calls:

  - {:city_from, geohash} - for getting city based on given `geohash`,
  - {:airly_station_from, geohash} - for getting Airly station ID based on given `geohash`,
  - {:gios_station_from, geohash} - for getting GIOŚ station ID based on given `geohash`.
  """
  def handle_call({:city_from, geohash}, _from, %{ cities: cities } = state) do
    {:reply, single_by_geohash(cities, geohash), state}
  end

  def handle_call({:airly_station_from, geohash}, _from, %{ airly: stations } = state) do
    {:reply, single_by_geohash(stations, geohash), state}
  end

  def handle_call({:gios_station_from, geohash}, _from, %{ gios: stations } = state) do
    {:reply, single_by_geohash(stations, geohash), state}
  end

  defp single_by_geohash(list, geohash) do
    case Enum.filter(list, fn(entity) -> is_geohash_inside_another_one?(geohash, entity[:geohash]) end) do
      []         -> :error
      results    -> hd(results)
    end
  end
end
