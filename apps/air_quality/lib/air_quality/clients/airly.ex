defmodule AirQuality.Clients.Airly do
  @moduledoc """
  Module which represents Airly API HTTP(S) client.
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://airapi.airly.eu"
  plug Tesla.Middleware.JSON

  plug Tesla.Middleware.Headers, [
    {"apikey", Application.get_env(:air_quality, :api_keys)[:airly]}
  ]

  require Logger

  @doc """
  Retrieve station data about air quality from Airly API based
  on their sensor ID.
  """
  def get_station_data(id) do
    result = get("/v1/sensor/measurements", query: [ sensorId: id ])
    transform_response(result)
  end

  defp transform_response({:ok, %Tesla.Env{status: 200} = environment}) do
    response = %{
      type: :airly,
      pm_2_5: environment.body["currentMeasurements"]["pm25"],
      pm_10: environment.body["currentMeasurements"]["pm10"]
    }

    {:ok, response}
  end

  defp transform_response({:ok, %Tesla.Env{status: 500} = environment}) do
    Logger.error("[AIRLY] Received unexpected result when fetching station data: #{inspect environment}")
    {:error, :server_error}
  end

  defp transform_response({:ok, %Tesla.Env{status: 400} = environment}) do
    Logger.error("[AIRLY] Received unexpected result when fetching station data: #{inspect environment}")
    {:error, :invalid_request}
  end

  defp transform_response({:ok, %Tesla.Env{status: 401} = environment}) do
    Logger.error("[AIRLY] Received unexpected result when fetching station data: #{inspect environment}")
    {:error, :wrong_api_key}
  end

  defp transform_response({:ok, %Tesla.Env{status: 403} = environment}) do
    Logger.error("[AIRLY] Received unexpected result when fetching station data: #{inspect environment}")
    {:error, :forbidden}
  end

  defp transform_response({:ok, %Tesla.Env{status: 404} = environment}) do
    Logger.error("[AIRLY] Received unexpected result when fetching station data: #{inspect environment}")
    {:error, :no_such_station}
  end

  defp transform_response({:ok, %Tesla.Env{status: 429} = environment}) do
    Logger.error("[AIRLY] Received unexpected result when fetching station data: #{inspect environment}")
    {:error, :api_limit_exceeded}
  end

  defp transform_response({:error, reason}) do
    Logger.error("[AIRLY] Received unexpected result when connecting to station data API: #{inspect reason}")
    {:error, :connection_error}
  end
end
