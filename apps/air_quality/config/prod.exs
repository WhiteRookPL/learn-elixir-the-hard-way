use Mix.Config

config :air_quality, :cache,
  ttl_in_seconds: 24 * 60 * 60

import_config "prod.secret.exs"
