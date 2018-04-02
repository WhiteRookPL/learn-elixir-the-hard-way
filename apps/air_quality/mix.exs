defmodule AirQuality.Mixfile do
  use Mix.Project

  def project do
    [
      app: :air_quality,
      version: "1.0.0",

      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",

      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),

      start_permanent: Mix.env == :prod,

      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {AirQuality.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:tesla, "~> 1.0.0-beta.1"},
      {:jason, "~> 1.0"},
      {:ibrowse, "~> 4.4"}
    ]
  end

  defp aliases do
    []
  end
end
