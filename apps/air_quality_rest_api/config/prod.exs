use Mix.Config

config :air_quality_rest_api, AirQualityRestAPI.Endpoint,
  load_from_system_env: true,
  url: [
    port: "${PORT}"
  ],
  check_origin: false,
  server: true,
  root: ".",
  cache_static_manifest: "priv/static/cache_manifest.json"

import_config "prod.secret.exs"
