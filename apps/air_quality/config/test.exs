use Mix.Config

config :air_quality, :cache,
  ttl_in_seconds: 1

config :tesla, adapter: Tesla.Mock
