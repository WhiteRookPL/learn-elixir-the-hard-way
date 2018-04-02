use Mix.Config

config :tesla, :adapter, Tesla.Adapter.Ibrowse

config :air_quality, :cache,
  ttl_in_seconds: 10

import_config "#{Mix.env}.exs"
