defmodule AirQualityRestAPI.ConditionsController do
  use AirQualityRestAPI, :controller

  def index(conn, %{"lat" => lat, "lng" => lng}) do
    {latitude, ""} = Float.parse(lat)
    {longitude, ""} = Float.parse(lng)

    result = AirQuality.Facade.get_weather_and_air_quality_for(latitude, longitude)

    conn
    |> put_status(200)
    |> json(result)
  end

  def index(conn, _params) do
    conn
    |> put_status(400)
    |> text("Missing latitude and longitude.")
  end
end
