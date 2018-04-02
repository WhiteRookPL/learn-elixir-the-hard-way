defmodule AirQuality.Application do
  @moduledoc """
  The AirQuality Application Service.

  The air_quality system business domain lives in this application.

  Exposes API to clients such as the `AirQualityAPI` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [
        {AirQuality.Cache.CacheServer, [name: CacheServer]},
        {AirQuality.Cache.PreprocessedCacheServer, [name: PreprocessedCacheServer]}
      ],
      strategy: :one_for_one,
      name: AirQuality.Supervisor
    )
  end
end
