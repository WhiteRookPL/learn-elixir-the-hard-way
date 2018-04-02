defmodule AirQualityRestAPI.Mixfile do
  use Mix.Project

  def project do
    [
      app: :air_quality_rest_api,
      version: "1.0.0",

      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",

      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),

      compilers: [:phoenix, :gettext] ++ Mix.compilers,

      start_permanent: Mix.env == :prod,

      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {AirQualityRestAPI.Application, []},
      extra_applications: [:logger, :runtime_tools, :wobserver]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:jason, "~> 1.0"},

      {:gettext, "~> 0.11"},

      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix, "~> 1.3.2"},

      {:cowboy, "~> 1.0"},

      {:wobserver, "~> 0.1"},
      {:air_quality, in_umbrella: true}
    ]
  end

  defp aliases do
    []
  end
end
