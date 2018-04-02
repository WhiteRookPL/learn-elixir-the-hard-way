defmodule AirQuality.Cache.ProcessedCacheServerTest do
  use ExUnit.Case

  test "City should be fetched via geohash" do
    city = AirQuality.Cache.PreprocessedCacheServer.city(PreprocessedCacheServer, "u3psyxaw2")

    assert city[:city] == "Żyrzyn"
  end

  test "When no city could be fetched via geohash we return :error" do
    result = AirQuality.Cache.PreprocessedCacheServer.city(PreprocessedCacheServer, "zzzzzzzzz")

    assert result == :error
  end

  test "Airly station data should be fetched via geohash" do
    station = AirQuality.Cache.PreprocessedCacheServer.airly_station(PreprocessedCacheServer, "u2yjj523a")

    assert station[:id] == 129
  end

  test "When no Airly station could be fetched via geohash we return :error" do
    result = AirQuality.Cache.PreprocessedCacheServer.airly_station(PreprocessedCacheServer, "zzzzzzzzz")

    assert result == :error
  end

  test "GIOŚ station data should be fetched via geohash" do
    station = AirQuality.Cache.PreprocessedCacheServer.gios_station(PreprocessedCacheServer, "u3h4y1asd2")

    assert station[:id] == 114
  end

  test "When no GIOŚ station could be fetched via geohash we return :error" do
    result = AirQuality.Cache.PreprocessedCacheServer.gios_station(PreprocessedCacheServer, "zzzzzzzzz")

    assert result == :error
  end
end
