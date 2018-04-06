defmodule AirQuality.Utilities.GeoHash do
  @moduledoc """
  A simple implementation for GeoHash calculation in Elixir.
  """

  @base32_word_size 5
  @base32_alphabet  "0123456789bcdefghjkmnpqrstuvwxyz"

  @doc """
    Converts provided bits into a geohash, taking `base32` as a default alphabet.

      iex> AirQuality.Utilities.GeoHash.to_geohash(<<0::5>>)
      "0"

      iex> AirQuality.Utilities.GeoHash.to_geohash(<<31::5>>)
      "z"

      iex> AirQuality.Utilities.GeoHash.to_geohash(<<0::1,0::1,1::1,0::1,1::1>>)
      "5"

      iex> AirQuality.Utilities.GeoHash.to_geohash(<<>>)
      ""

      iex> AirQuality.Utilities.GeoHash.to_geohash(<<0::5>>, "ab", 1)
      "aaaaa"

      iex> AirQuality.Utilities.GeoHash.to_geohash(<<31::5>>, "ab", 1)
      "bbbbb"

      iex> AirQuality.Utilities.GeoHash.to_geohash(<<10::5>>, "ab", 1)
      "ababa"
  """
  def to_geohash(bits, alphabet \\ @base32_alphabet, word_size \\ @base32_word_size) do
    # ???
    nil
  end

  @min_lat -90
  @max_lat +90

  @min_lng -180
  @max_lng +180

  def to_base32_geohash(lat, lng, length \\ 4)
    when length > 0 and
         lat >= @min_lat and
         lat <= @max_lat and
         lng >= @min_lng and
         lng <= @max_lng
  do
    result = _encode(0, length * @base32_word_size, @min_lat, @max_lat, @min_lng, @max_lng, lat, lng, <<>>)
    to_geohash(result)
  end

  defp _encode(i, precision, _minLat, _maxLat, _minLng, _maxLng, _lat, _lng, result) when i >= precision do
    result
  end

  defp _encode(i, precision, minLat, maxLat, minLng, maxLng, lat, lng, result) when rem(i, 2) == 0 do
    midpoint = (minLng + maxLng) / 2

    if lng < midpoint do
      _encode(i + 1, precision, minLat, maxLat, minLng, midpoint, lat, lng, <<result::bitstring, 0::1>>)
    else
      _encode(i + 1, precision, minLat, maxLat, midpoint, maxLng, lat, lng, <<result::bitstring, 1::1>>)
    end
  end

  defp _encode(i, precision, minLat, maxLat, minLng, maxLng, lat, lng, result) when rem(i, 2) == 1 do
    midpoint = (minLat + maxLat) / 2

    if lat < midpoint do
      _encode(i + 1, precision, minLat, midpoint, minLng, maxLng, lat, lng, <<result::bitstring, 0::1>>)
    else
      _encode(i + 1, precision, midpoint, maxLat, minLng, maxLng, lat, lng, <<result::bitstring, 1::1>>)
    end
  end

  def is_location_inside_geohash?(lat, lng, origin) do
    location = AirQuality.Utilities.GeoHash.to_base32_geohash(lat, lng, 10)
    is_geohash_inside_another_one?(location, origin)
  end

  def is_geohash_inside_another_one?(geohash, bigger_geohash) do
    String.starts_with?(geohash, bigger_geohash)
  end
end
