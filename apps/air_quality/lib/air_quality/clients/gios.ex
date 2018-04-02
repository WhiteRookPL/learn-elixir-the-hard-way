defmodule AirQuality.Clients.GIOS do
  @moduledoc """
  Module which represents GIOŚ API HTTP(S) client.
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://api.gios.gov.pl"
  plug Tesla.Middleware.JSON

  require Logger

  @doc """
  Retrieve station data about air quality from GIOŚ API based
  on their sensor ID.
  """
  def get_station_data(id) do
    result = get("/pjp-api/rest/station/sensors/#{id}")
    transform_sensors_response(result)
  end

  defp transform_sensors_response({:ok, %Tesla.Env{status: 200} = environment}) do
    results =
      environment.body
      |> Enum.filter(fn(sensor) -> String.starts_with?(sensor["param"]["paramCode"], "PM") end)
      |> Enum.map(fn(sensor) -> get_sensor_measurements(sensor["id"], sensor["param"]["paramCode"]) end)

    response = %{
      type: :gios,
      pm_2_5: get_value_for("PM25", results),
      pm_10: get_value_for("PM10", results)
    }

    {:ok, response}
  end

  defp transform_sensors_response({:ok, %Tesla.Env{status: 500} = environment}) do
    Logger.error("[GIOS] Received unexpected result when fetching sensors: #{inspect environment}")
    {:error, :server_error}
  end

  defp transform_sensors_response({:ok, %Tesla.Env{status: 400} = environment}) do
    Logger.error("[GIOS] Received unexpected result when fetching sensors: #{inspect environment}")
    {:error, :invalid_request}
  end

  defp transform_sensors_response({:ok, %Tesla.Env{status: 401} = environment}) do
    Logger.error("[GIOS] Received unexpected result when fetching sensors: #{inspect environment}")
    {:error, :wrong_api_key}
  end

  defp transform_sensors_response({:ok, %Tesla.Env{status: 403} = environment}) do
    Logger.error("[GIOS] Received unexpected result when fetching sensors: #{inspect environment}")
    {:error, :api_limit_exceeded}
  end

  defp transform_sensors_response({:ok, %Tesla.Env{status: 404} = environment}) do
    Logger.error("[GIOS] Received unexpected result when fetching sensors: #{inspect environment}")
    {:error, :no_such_station}
  end

  defp transform_sensors_response({:error, reason}) do
    Logger.error("[GIOS] Received unexpected result when connecting to sensors API: #{inspect reason}")
    {:error, :connection_error}
  end

  defp get_sensor_measurements(sensor_id, parameter) do
    result = get("/pjp-api/rest/data/getData/#{sensor_id}")
    transform_sensor_measurements_response(result, parameter)
  end

  defp transform_sensor_measurements_response({:ok, %Tesla.Env{status: 200} = environment}, parameter) do
    %{
      key: parameter,
      value: List.last(environment.body["values"])["value"]
    }
  end

  defp transform_sensor_measurements_response(result, parameter) do
    Logger.error("[GIOS] Received unexpected result when fetching sensor measurements: #{inspect result}")

    %{
      key: parameter,
      value: 0.0
    }
  end

  defp get_value_for(parameter, results) do
    result =
      results
      |> Enum.filter(fn(measurement) -> measurement[:key] == parameter end)

    case result do
      [] -> 0.0
      [ final_result ] -> final_result[:value]
    end
  end
end
