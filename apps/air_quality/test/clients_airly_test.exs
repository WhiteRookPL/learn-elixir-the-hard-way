defmodule AirQuality.Clients.AirlyTest do
  use ExUnit.Case

  import Tesla.Mock

  setup do
    mock fn
      %{method: :get, url: "https://airapi.airly.eu/v1/sensor/measurements", query: [sensorId: 100]} ->
        %Tesla.Env{
          status: 200,
          body: %{
           "currentMeasurements" => %{
              "airQualityIndex" => 81.0772869875223,
              "humidity" => 57.44278330933986,
              "pm1" => 56.92083654901961,
              "pm10" => 96.76956798584567,
              "pm25" => 68.37003137254905,
              "pollutionLevel" => 4,
              "pressure" => 100757.882054946,
              "temperature" => 15.79455882352941
            },
            "forecast" => [],
            "history" => []
          }
        }

      %{method: :get, url: "https://airapi.airly.eu/v1/sensor/measurements", query: [sensorId: 101]} ->
        %Tesla.Env{
          status: 500,
          body: "Error!"
        }

      %{method: :get, url: "https://airapi.airly.eu/v1/sensor/measurements", query: [sensorId: 102]} ->
        %Tesla.Env{
          status: 429,
          body: "Too many requests!"
        }
    end

    :ok
  end

  test "Testing successful GET request to Airly API via our client" do
    assert {:ok, result} = AirQuality.Clients.Airly.get_station_data(100)

    assert result[:pm_10] == 96.76956798584567
    assert result[:pm_2_5] == 68.37003137254905
  end

  test "Testing not successful GET request to Airly API via our client" do
    assert {:error, :server_error} = AirQuality.Clients.Airly.get_station_data(101)
  end

  test "Testing throttled GET request to Airly API via our client" do
    assert {:error, :api_limit_exceeded} = AirQuality.Clients.Airly.get_station_data(102)
  end
end
