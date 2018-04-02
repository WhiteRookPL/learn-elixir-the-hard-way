# Release and Deployment

## Release

The Erlang documentation describes *releases* as “complete systems” of one or more applications:

> When you have written one or more applications, you might want to create a complete
> system with these applications and a subset of the Erlang/OTP applications.
> This is called a release.

What does that mean? Releases are packages of compiled Erlang/Elixir code (i.e. BEAM bytecode). On top of that, they contain metadata and utility scripts for launching and managing the application as a whole.

Releases may also contain the Erlang runtime (ERTS, short for Erlang Runtime System Application). Releases that include ERTS are almost completely self-contained. They have no external dependencies except for true essentials such as `libc` or `openssl` (if you're using the `:crypto` application).

### Installing `distillery`

Add distillery to your application's dependencies. In the `mix.exs` file, add `{:distillery, "~> 1.5"}` to the dependencies. Then install it by running:

```bash
$ mix do deps.get, deps.compile
```

### Creating release definition

```bash
$ mix release.init
```

### Configuring `phoenix`

```elixir
config :air_quality_rest_api, AirQualityRestAPI.Endpoint,
  load_from_system_env: true,
  url: [
    port: "${PORT}"
  ],
  check_origin: false,
  server: true,
  root: ".",
  cache_static_manifest: "priv/static/cache_manifest.json"
```

### Building release

```bash
$ MIX_ENV=prod mix release --env=prod
```

### The anatomy of a release

Let's analyze how release looks inside after bundling.

### Testing release locally

```bash
$ PORT=8080 _build/prod/rel/learn-elixir-the-hard-way/bin/learn-elixir-the-hard-way foreground
```

## Deployment

### Configure runtime

Create a file called `app.yaml` at the root of the application directory, as [it is present](app.yaml) in this repository.

### Deploy

Create new project, unless you already have one. Remember that, you need to enable billing in your project.

```bash
$ gcloud app deploy
```

When *CLI* will ask about region, I strongly recommend to use `europe-west3` (which points into *Frankfurt* *DC*) as it is the closest one to us.

### Review setup application

```bash
$ gcloud app browse
```

### Cleanup

```bash
gcloud projects delete [YOUR_PROJECT_ID]
```

For us `[YOUR_PROJECT_ID]` is equal to `learn-elixir-the-hard-way`.
