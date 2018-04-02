use Mix.Config

config :air_quality_rest_api,
  namespace: AirQualityRestAPI

config :air_quality_rest_api, AirQualityRestAPI.Endpoint,
  url: [
    host: "localhost"
  ],
  secret_key_base: "F+9TIBjVivMj2uDooQAOC+4ypsSH8CbOY8WjNC9MUlkUmwHg8AzH+qZu5LFZKkHd",
  render_errors: [
    view: AirQualityRestAPI.ErrorView,
    accepts: ~w(json)
  ],
  pubsub: [
    name: AirQualityRestAPI.PubSub,
    adapter: Phoenix.PubSub.PG2
  ]

config :phoenix, :format_encoders,
  json: Jason

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :air_quality_rest_api, :generators,
  context_app: :air_quality

import_config "#{Mix.env}.exs"
