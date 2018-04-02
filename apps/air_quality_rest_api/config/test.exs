use Mix.Config

config :air_quality_rest_api, AirQualityRestAPI.Endpoint,
  http: [
    port: 4001
  ],
  server: false
