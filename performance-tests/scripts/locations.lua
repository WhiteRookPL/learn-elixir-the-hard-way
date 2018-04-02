function load_csv(file)
  lines = {}

  local f = io.open(file, "r")

  if f ~= nil then
    io.close(f)
  else
    return lines
  end

  for line in io.lines(file) do
    if not (line == '') then
      lines[#lines + 1] = line
    end
  end

  return lines
end

math.randomseed(os.time())

locations = load_csv("./data/locations.csv")

print("[ii] Found " .. #locations .. " locations")

function randomize_and_trim(tab)
  return tab[math.random(#tab)]:gsub("^%s*(.-)%s*$", "%1")
end

function request()
  lat, lng = randomize_and_trim(locations):match("([^,]+),([^,]+)")

  url = string.format("/api/conditions?lat=%f&lng=%f", lat, lng)

  wrk.headers["User-Agent"] = "wrk2 / learn-elixir-the-hard-way"

  return wrk.format(nil, url)
end

function done(summary, latency, requests)
   io.write("------------------------------\n")
   io.write(string.format("- Throughput: %.2f request / s\n", (summary.requests / summary.duration) * 1000000))
   io.write("- Latency:\n")
   for _, p in pairs({ 50, 90, 99, 99.999 }) do
      n = latency:percentile(p)
      io.write(string.format("  - %g%% = %.3f ms\n", p, n / 1000))
   end
end
