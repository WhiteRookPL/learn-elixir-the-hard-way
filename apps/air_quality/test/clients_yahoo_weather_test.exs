defmodule AirQuality.Clients.YahooWeatherTest do
  use ExUnit.Case

  import Tesla.Mock

  @validYQL AirQuality.Clients.YahooWeather.yql("Gliwice")
  @invalidYQL AirQuality.Clients.YahooWeather.yql("Sosnowiec")
  @limitedYQL AirQuality.Clients.YahooWeather.yql("Zakopane")

  setup do
    mock fn
      %{method: :get, url: "https://query.yahooapis.com/v1/public/yql", query: [q: @validYQL, format: "json"]} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "query" => %{
              "count" => 1,
              "created" => "2018-04-04T17:44:21Z",
              "lang" => "en-US",
              "results" => %{
                "channel" => %{
                  "atmosphere" => %{
                    "humidity" => "51",
                    "pressure" => "33152.76",
                    "rising" => "0",
                    "visibility" => "25.91"
                  },
                  "item" => %{
                    "condition" => %{
                      "code" => "27",
                      "date" => "Wed, 04 Apr 2018 08:00 PM CEST",
                      "temp" => "15",
                      "text" => "Mostly Cloudy"
                    }
                  },
                  "units" => %{
                    "distance" => "km",
                    "pressure" => "mb",
                    "speed" => "km/h",
                    "temperature" => "C"
                  },
                  "wind" => %{
                    "chill" => "57",
                    "direction" => "185",
                    "speed" => "22.53"
                  }
                }
              }
            }
          }
        }

      %{method: :get, url: "https://query.yahooapis.com/v1/public/yql", query: [q: @invalidYQL, format: "json"]} ->
        %Tesla.Env{
          status: 500,
          body: "Error!"
        }

      %{method: :get, url: "https://query.yahooapis.com/v1/public/yql", query: [q: @limitedYQL, format: "json"]} ->
        %Tesla.Env{
          status: 403,
          body: "Too many requests!"
        }
    end

    :ok
  end

  test "Testing successful GET request to Yahoo Weather API via our client" do
    assert {:ok, result} = AirQuality.Clients.YahooWeather.current_conditions("Gliwice")

    assert result[:temperature] == "15 C"
    assert result[:pressure] == "981.7658468691236 hPa"
    assert result[:humidity] == "51 %"
    assert result[:wind] == "22.53 km/h"
    assert result[:description] == "Mostly Cloudy"
  end

  test "Testing not successful GET request to Yahoo Weather API via our client" do
    assert {:error, :server_error} = AirQuality.Clients.YahooWeather.current_conditions("Sosnowiec")
  end

  test "Testing throttled GET request to Yahoo Weather API via our client" do
    assert {:error, :api_limit_exceeded} = AirQuality.Clients.YahooWeather.current_conditions("Zakopane")
  end
end
