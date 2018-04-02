# Installation Guide

## Version Manager

At first, install *extensible version manager* [asdf](https://github.com/asdf-vm/asdf) and support for your favorite shell.

Then install following plugins:

```bash
$ asdf plugin-add erlang
$ asdf plugin-add elixir
$ asdf plugin-add nodejs
```

## Platorm-specific dependencies

### Linux

You need to install `inotify-tools` package in order to support code-reloading.

Example for *Fedora* *Linux* distribution:

```bash
$ sudo dnf install inotify-tools
```

For using `:observer` you need to install locally `wxWidgets` or compatible *UI* back-end.

Example for *Fedora* *Linux* distribution:

```bash
sudo dnf install wxGTK3-devel mesa-libGL-devel mesa-libGLU-devel
```

### OSX

For using `:observer` you need to install locally `wxmac`:

```bash
$ brew install wxmac
```

## Erlang

```bash
$ asdf install erlang 20.3
```

## Elixir

```bash
$ asdf install elixir 1.6.4
```

In order to enable shell history, please add this somewhere to your favorite's shell configuration files:

```bash
export ERL_AFLAGS="-kernel shell_history enabled"
```

### Hex

```bash
$ mix local.hex
```

### `rebar3`

```bash
$ mix local.rebar --force
````

### Phoenix

```bash
$ mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez
```

## Node.js

```bash
$ asdf install nodejs 6.10.3
```

## Testing

```bash
$ erl -version
$ elixir --version
$ node -v
$ mix deps.get
$ mix test
```

## Creating new application from scratch

```bash
$ mix phx.new . --umbrella --app air_quality --no-brunch --no-ecto --no-html
```

## Google Cloud SDK

Follow instructions specific for your operating system from [here](https://cloud.google.com/sdk/). Then proceed with configuration and authorization of your account:

```bash
$ gcloud init
```

I would like to recommend creating separate project for that repository, it will be easier perform a cleanup later.
