defmodule AirQualityRestAPI.Router do
  use AirQualityRestAPI, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AirQualityRestAPI do
    pipe_through :api

    get "/conditions", ConditionsController, :index
  end

  forward "/wobserver", Wobserver.Web.Router
end
