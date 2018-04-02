defmodule AirQuality.Facade do
  @moduledoc """
  Module which covers and orchestrates required calls used when fetching
  weather and air quality metrics for a given location.
  """

  require Logger

  @doc """
  Retrieve weather and air quality metrics from cache or external services
  and returning the result in unified way.
  """
  def get_weather_and_air_quality_for(lat, lng) do
    geohash = AirQuality.Utilities.GeoHash.to_base32_geohash(lat, lng, 6)

    city = AirQuality.Cache.PreprocessedCacheServer.city(PreprocessedCacheServer, geohash)

    airly_station = AirQuality.Cache.PreprocessedCacheServer.airly_station(PreprocessedCacheServer, geohash)
    gios_station = AirQuality.Cache.PreprocessedCacheServer.gios_station(PreprocessedCacheServer, geohash)

    results = case AirQuality.Cache.CacheServer.lookup(CacheServer, geohash) do
      :error ->
        Logger.info("[FACADE] Cache miss! Fetching data for a following geohash: #{geohash}")

        jobs = %{
          :weather => fn() -> fetch_weather(city) end,
          :airly => fn() -> fetch_airly_station(airly_station) end,
          :gios => fn() -> fetch_gios_station(gios_station) end
        }

        values =
          jobs
          |> Enum.reduce([], fn({key, job}, intermediate) -> [{key, Task.async(job)} | intermediate] end)
          |> Enum.map(fn({key, task}) -> {key, Task.await(task)} end)
          |> Enum.map(&extract_value/1)
          |> Enum.into(%{})

        AirQuality.Cache.CacheServer.cache(CacheServer, geohash, values)
        values

      {:ok, values} ->
        values
    end

    %{:geohash => geohash, :results => results}
  end

  defp fetch_weather(:error), do: {:error, :missing_entry}
  defp fetch_weather(city), do: AirQuality.Clients.YahooWeather.current_conditions(city[:city])

  defp fetch_airly_station(:error), do: {:error, :missing_entry}
  defp fetch_airly_station(airly_station), do: AirQuality.Clients.Airly.get_station_data(airly_station[:id])

  defp fetch_gios_station(:error), do: {:error, :missing_entry}
  defp fetch_gios_station(gios_station), do: AirQuality.Clients.GIOS.get_station_data(gios_station[:id])

  defp extract_value({key, {:ok, result}}), do: {key, result}
  defp extract_value({key, {:error, _}}), do: {key, :error}
end
