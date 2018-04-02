defmodule AirQuality.Clients.GIOSTest do
  use ExUnit.Case

  import Tesla.Mock

  setup do
    mock fn
      %{method: :get, url: "http://api.gios.gov.pl/pjp-api/rest/station/sensors/100"} ->
        %Tesla.Env{
          status: 200,
          body: [
            %{
              "id" => 92,
              "stationId" => 14,
              "param" => %{
                "paramName" => "pył zawieszony PM10",
                "paramFormula" => "PM10",
                "paramCode" => "PM10",
                "idParam" => 3
              }
            },
            %{
              "id" => 88,
              "stationId" => 14,
              "param" => %{
                "paramName" => "pył zawieszony PM25",
                "paramFormula" => "PM25",
                "paramCode" => "PM25",
                "idParam" => 6
              }
            }
          ]
        }

      %{method: :get, url: "http://api.gios.gov.pl/pjp-api/rest/data/getData/92"} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "key" => "PM10",
            "values" => [
              %{
                "date" => "2017-03-28 11:00:00",
                "value" => 30.3018
              },
              %{
                "date" => "2017-03-28 12:00:00",
                "value" => 92.9292
              }
            ]
          }
        }

      %{method: :get, url: "http://api.gios.gov.pl/pjp-api/rest/data/getData/88"} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "key" => "PM25",
            "values" => [
              %{
                "date" => "2017-03-28 11:00:00",
                "value" => 30.3018
              },
              %{
                "date" => "2017-03-28 12:00:00",
                "value" => 88.8888
              }
            ]
          }
        }

      %{method: :get, url: "http://api.gios.gov.pl/pjp-api/rest/station/sensors/101"} ->
        %Tesla.Env{
          status: 500,
          body: "Error!"
        }

      %{method: :get, url: "http://api.gios.gov.pl/pjp-api/rest/station/sensors/102"} ->
        %Tesla.Env{
          status: 403,
          body: "Too many requests!"
        }
    end

    :ok
  end

  test "Testing successful GET request to GIOS API via our client" do
    assert {:ok, result} = AirQuality.Clients.GIOS.get_station_data(100)

    assert result[:pm_10] == 92.9292
    assert result[:pm_2_5] == 88.8888
  end

  test "Testing not successful GET request to GIOS API via our client" do
    assert {:error, :server_error} = AirQuality.Clients.GIOS.get_station_data(101)
  end

  test "Testing throttled GET request to GIOS API via our client" do
    assert {:error, :api_limit_exceeded} = AirQuality.Clients.GIOS.get_station_data(102)
  end
end
