use Mix.Config

config :air_quality_rest_api, AirQualityRestAPI.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []
