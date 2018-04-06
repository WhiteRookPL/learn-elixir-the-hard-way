# Testing

## Manual Testing

### `localhost` examples

```bash
# Skyrise HQ:
$ curl -X GET -v "http://localhost:8080/api/conditions?lat=50.262858&lng=19.013808" | jq

# Hackerspace Silesia HQ:
$ curl -X GET -v "http://localhost:8080/api/conditions?lat=50.2641006&lng=18.9936806" | jq

# Gliwice Sikornik:
$ curl -X GET -v "http://localhost:8080/api/conditions?lat=50.2774207&lng=18.6481976" | jq
```

### *Google Cloud Platform examples (*App Engine*)

```bash
# Skyrise HQ:
$ curl -X GET -v "https://learn-elixir-the-hard-way.appspot.com/api/conditions?lat=50.262858&lng=19.013808" | jq

# Hackerspace Silesia HQ:
$ curl -X GET -v "https://learn-elixir-the-hard-way.appspot.com/api/conditions?lat=50.2641006&lng=18.9936806" | jq

# Gliwice Sikornik:
$ curl -X GET -v "https://learn-elixir-the-hard-way.appspot.com/api/conditions?lat=50.2774207&lng=18.6481976" | jq
```

## Using `:observer` tool and introspecting `localhost` release

```bash
# First terminal:
$ PORT=8080 _build/prod/rel/learn_elixir_the_hard_way/bin/learn_elixir_the_hard_way foreground

# Second terminal:
$ iex --name lethw_debug@127.0.0.1 --cookie "PASTE_HERE_COOKIE_FROM_RELEASE"
```

And then inside `iex` shell:

```elixir
iex> Node.connect(:'learn_elixir_the_hard_way@127.0.0.1')
iex> :observer.start
```

If you are using dark theme and *GTK3* you may want to use light one. You need to prefix you `iex` command with this:

```bash
$ GTK_THEME=Adwaita:light iex --name lethw_debug@127.0.0.1 --cookie "PASTE_HERE_COOKIE_FROM_RELEASE"
```

## Using `wobserver` tool and introspecting remote release

After deploying application inside *app engine* in *GCP* you should be able to do *API* requests at address `https://learn-elixir-the-hard-way.appspot.com`. You will be able to see also a nice dashboard when hitting following link: `https://learn-elixir-the-hard-way.appspot.com/wobserver`.

This nice dashboard is also available on `localhost` without any issues.

## Performance Tests

If you want to test performance of the local release you should be able to run following script from `performance-tests` directory:

```bash
$ ./performance-tests.sh localhost
```

To performing exactly the same scenario remotely, you can run it with:

```bash
$ ./performance-tests.sh gcp
```

### Performance Issue?

#### Description

So after running those tests (does not matter if locally or remotely) we discovered that *API* responds a little bit slowly, in case of parallel requests. Individual requests are pretty fast, but for concurrent access we are observing significantly slower response.

#### Reason

Shouldn't actor model help us in such situations? It will, if we will design it properly. In our case we did a terrible mistake, and we created a *bottleneck*. One of our servers stores huge state and we are querying it for every single request.

#### Solution

How to avoid that? We can do a simple implementation change and move such internal state from `GenServer* into `:ets`. Here is the example implementation, let's analyze that:

```diff
diff --git a/apps/air_quality/lib/air_quality/cache/preprocessed_cache.ex b/apps/air_quality/lib/air_quality/cache/preprocessed_cache.ex
index a015a53..bce7c00 100644
--- a/apps/air_quality/lib/air_quality/cache/preprocessed_cache.ex
+++ b/apps/air_quality/lib/air_quality/cache/preprocessed_cache.ex
@@ -5,8 +5,6 @@ defmodule AirQuality.Cache.PreprocessedCacheServer do

   use GenServer

-  import AirQuality.Utilities.GeoHash, only: [is_geohash_inside_another_one?: 2]
-
   ### Client API

   @doc """
@@ -53,10 +51,22 @@ defmodule AirQuality.Cache.PreprocessedCacheServer do
   def init(:ok) do
     {:ok, cities} = AirQuality.Utilities.Preprocessing.process_cities

-    {:ok, gios_stations} = AirQuality.Utilities.Preprocessing.process_stations("gios")
     {:ok, airly_stations} = AirQuality.Utilities.Preprocessing.process_stations("airly")
+    {:ok, gios_stations} = AirQuality.Utilities.Preprocessing.process_stations("gios")
+
+    cities_table = :ets.new(__MODULE__, [:private, :duplicate_bag])
+    airly_stations_table = :ets.new(__MODULE__, [:private, :duplicate_bag])
+    gios_stations_table = :ets.new(__MODULE__, [:private, :duplicate_bag])
+
+    insert_entries(cities_table, cities)
+    insert_entries(airly_stations_table, airly_stations)
+    insert_entries(gios_stations_table, gios_stations)
+
+    {:ok, {cities_table, airly_stations_table, gios_stations_table}}
+  end

-    {:ok, %{ cities: cities, gios: gios_stations, airly: airly_stations }}
+  defp insert_entries(table, list) do
+    Enum.each(list, fn(entry) -> :ets.insert(table, {entry[:geohash], entry}) end)
   end

   @doc """
@@ -68,22 +78,22 @@ defmodule AirQuality.Cache.PreprocessedCacheServer do
   - {:airly_station_from, geohash} - for getting Airly station ID based on given `geohash`,
   - {:gios_station_from, geohash} - for getting GIOŚ station ID based on given `geohash`.
   """
-  def handle_call({:city_from, geohash}, _from, %{ cities: cities } = state) do
-    {:reply, single_by_geohash(cities, geohash), state}
+  def handle_call({:city_from, geohash}, _from, {cities_table, _, _} = state) do
+    {:reply, fetch(cities_table, geohash), state}
   end

-  def handle_call({:airly_station_from, geohash}, _from, %{ airly: stations } = state) do
-    {:reply, single_by_geohash(stations, geohash), state}
+  def handle_call({:airly_station_from, geohash}, _from, {_, airly_stations_table, _} = state) do
+    {:reply, fetch(airly_stations_table, geohash), state}
   end

-  def handle_call({:gios_station_from, geohash}, _from, %{ gios: stations } = state) do
-    {:reply, single_by_geohash(stations, geohash), state}
+  def handle_call({:gios_station_from, geohash}, _from, {_, _, gios_stations_table} = state) do
+    {:reply, fetch(gios_stations_table, geohash), state}
   end

-  defp single_by_geohash(list, geohash) do
-    case Enum.filter(list, fn(entity) -> is_geohash_inside_another_one?(geohash, entity[:geohash]) end) do
-      []         -> :error
-      results    -> hd(results)
+  defp fetch(table, geohash) do
+    case :ets.lookup(table, String.slice(geohash, 0, 5)) do
+      [{_, value} | _] -> value
+      []               -> :error
     end
   end
 end
```

Applying that patch:

```bash
$ git apply performance-tests/solution/performance-issue-fix.diff
```

And from now on performance test results will be much better.
