defmodule AirQuality.Clients.YahooWeather do
  @moduledoc """
  Module which represents Yahoo Weather API HTTP(S) client.
  """

  use Tesla

  @inhg2mb 33.7685

  plug Tesla.Middleware.BaseUrl, "https://query.yahooapis.com"
  plug Tesla.Middleware.JSON

  require Logger

  @doc """
  Retrieve current weather conditions based on the city name.
  """
  def current_conditions(city) do
    result = get("/v1/public/yql", query: [ q: yql(city), format: "json" ])
    transform_response(result)
  end

  @doc """
  Prepare YQL (*Yahoo Query Language*) statement which fetches weather
  conditions.
  """
  def yql(city) do
    woeid_yql = "select woeid from geo.places(1) where text='#{city}, Poland'"
    "select units, item.condition, atmosphere, wind from weather.forecast where woeid in (#{woeid_yql}) and u='c'"
  end

  defp transform_response({:ok, %Tesla.Env{status: 200} = environment}) do
    results = environment.body["query"]["results"]["channel"]
    pressure = String.to_float(results["atmosphere"]["pressure"]) / @inhg2mb

    response = %{
      temperature: "#{results["item"]["condition"]["temp"]} #{results["units"]["temperature"]}",
      pressure: "#{pressure} hPa",
      humidity: "#{results["atmosphere"]["humidity"]} %",
      wind: "#{results["wind"]["speed"]} #{results["units"]["speed"]}",
      description: results["item"]["condition"]["text"],
    }

    {:ok, response}
  end

  defp transform_response({:ok, %Tesla.Env{status: 500} = environment}) do
    Logger.error("[WEATHER] Received unexpected result when fetching current weather conditions: #{inspect environment}")
    {:error, :server_error}
  end

  defp transform_response({:ok, %Tesla.Env{status: 400} = environment}) do
    Logger.error("[WEATHER] Received unexpected result when fetching current weather conditions: #{inspect environment}")
    {:error, :invalid_request}
  end

  defp transform_response({:ok, %Tesla.Env{status: 401} = environment}) do
    Logger.error("[WEATHER] Received unexpected result when fetching current weather conditions: #{inspect environment}")
    {:error, :wrong_api_key}
  end

  defp transform_response({:ok, %Tesla.Env{status: 403} = environment}) do
    Logger.error("[WEATHER] Received unexpected result when fetching current weather conditions: #{inspect environment}")
    {:error, :api_limit_exceeded}
  end

  defp transform_response({:ok, %Tesla.Env{status: 404} = environment}) do
    Logger.error("[WEATHER] Received unexpected result when fetching current weather conditions: #{inspect environment}")
    {:error, :no_such_station}
  end

  defp transform_response({:error, reason}) do
    Logger.error("[WEATHER] Received unexpected result when connecting to weather API: #{inspect reason}")
    {:error, :connection_error}
  end
end
