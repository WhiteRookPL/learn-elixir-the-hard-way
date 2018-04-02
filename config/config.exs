use Mix.Config

import_config "../apps/*/config/config.exs"

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [
    :user_id
  ],
  compile_time_purge_level: :info

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true

config :wobserver,
  discovery: :none

import_config "#{Mix.env}.exs"
