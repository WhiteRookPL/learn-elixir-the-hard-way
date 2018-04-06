defmodule AirQuality.Utilities.Preprocessing do
  @moduledoc """
  Module with implementation for preprocessing cached JSON metadata, which
  helps us lower amount of API calls.
  """

  @geohash_precision 5

  @doc ~S"""
    Parses the file with air quality stations provided as
    a static asset in the application.

    ## Examples

      iex> AirQuality.Utilities.Preprocessing.process_stations("unknown")
      {:error, :unknown_station_file}

      iex> {:ok, stations} = AirQuality.Utilities.Preprocessing.process_stations("gios")
      iex> length(stations)
      162
      iex> hd(stations)
      %{
        id: 114,
        city: "Wrocław",
        street: "ul. Bartnicza",
        province: "dolnośląskie",
        country: "Poland",
        geohash: "u3h4y",
        lat: 51.115933,
        lng: 17.141125
      }

      iex> {:ok, stations} = AirQuality.Utilities.Preprocessing.process_stations("airly")
      iex> length(stations)
      1518
      iex> hd(stations)
      %{
        id: 129,
        city: "Zielonki",
        street: "Księdza Jana Michalika",
        province: "",
        country: "Poland",
        geohash: "u2yjj",
        lat: 50.116699999999994,
        lng: 19.914289999999998
      }
  """
  def process_stations(station_file) do
    with {:ok, content} <- File.read(Application.app_dir(:air_quality, "priv/#{station_file}.json")),
         {:ok, stations} <- Jason.decode(content)
    do
      result = for station <- stations do
        if station_file == "gios" do
          lat = String.to_float(station["gegrLat"])
          lng = String.to_float(station["gegrLon"])

          %{
            :id => station["id"],
            :lat => lat,
            :lng => lng,
            :geohash => AirQuality.Utilities.GeoHash.to_base32_geohash(lat, lng, @geohash_precision),
            :city => station["city"]["name"],
            :street => station["addressStreet"],
            :province => String.downcase(station["city"]["commune"]["provinceName"]),
            :country => "Poland"
          }
        else
          street = if Map.has_key?(station["address"], "route") do
            String.trim("#{station["address"]["route"]} #{station["address"]["street_number"]}")
          else
            ""
          end

          lat = station["location"]["latitude"]
          lng = station["location"]["longitude"]

          %{
            :id => station["id"],
            :lat => lat,
            :lng => lng,
            :geohash => AirQuality.Utilities.GeoHash.to_base32_geohash(lat, lng, @geohash_precision),
            :city => station["address"]["locality"],
            :street => street,
            :province => "",
            :country => station["address"]["country"]
          }
        end
      end

      {:ok, result}
    else
      {:error, :enoent} -> {:error, :unknown_station_file}
      _                 -> {:error, :unexpected_error}
    end
  end

  @doc ~S"""
    Parses the file with air quality stations provided as
    a static asset in the application.

    ## Examples

      iex> {:ok, cities} = AirQuality.Utilities.Preprocessing.process_cities
      iex> length(cities)
      2822
      iex> hd(cities)
      %{city: "Żyrzyn", geohash: "u3psy", lat: 51.49918, lng: 22.0917}
  """
  def process_cities() do
    with {:ok, content} <- File.read(Application.app_dir(:air_quality, "priv/cities.json")),
         {:ok, cities} <- Jason.decode(content),
         result <- cities
                   |> Enum.filter(fn(city) -> city["country"] == "PL" end)
                   |> Enum.map(fn(city) ->
                        lat = String.to_float(city["lat"])
                        lng = String.to_float(city["lng"])
                        %{
                          :lat => lat,
                          :lng => lng,
                          :geohash => AirQuality.Utilities.GeoHash.to_base32_geohash(lat, lng, @geohash_precision),
                          :city => city["name"]
                        }
                      end)
    do
      {:ok, result}
    else
      {:error, :enoent} -> {:error, :unknown_station_file}
      _                 -> {:error, :unexpected_error}
    end
  end
end
