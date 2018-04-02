use Mix.Releases.Config,
  default_release: :default,
  default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"jRN{J45^nn<x1%kN7Rw(yeXtQ1&<UI=/TyBhCHlH<*nTg<$76U0SCo2F?6<n%jC/"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"M)5gCJPe]tt>>u{15llva4Ncjd=a|Ew;NPMc`BE.fJ&cs4`xtdbNje`cz=%Z510O"
end

release :learn_elixir_the_hard_way do
  set version: "1.0.0"
  set applications: [
    :runtime_tools,
    :parse_trans,
    air_quality: :permanent,
    air_quality_rest_api: :permanent
  ]
end
