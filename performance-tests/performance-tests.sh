#!/usr/bin/env bash

MODE=${1:-"localhost"}
HOSTNAME="http://localhost:8080"

if [[ "${MODE}" == "gcp" ]]; then
  HOSTNAME="https://lethw-19052018.appspot.com"
fi

# Warm-up.

while read LINE; do
  LOCATION=(${LINE//,/ })
  curl -X GET -s "${HOSTNAME}/api/conditions?lat=${LOCATION[0]}&lng=${LOCATION[1]}" > /dev/null
done < data/locations.csv

# Actual performance test sessions.

wrk -t4  -c100 -d30s --timeout 2000 --script=./scripts/locations.lua --latency ${HOSTNAME}
wrk -t6  -c150 -d30s --timeout 2000 --script=./scripts/locations.lua --latency ${HOSTNAME}
wrk -t8  -c200 -d30s --timeout 2000 --script=./scripts/locations.lua --latency ${HOSTNAME}
wrk -t10 -c250 -d30s --timeout 2000 --script=./scripts/locations.lua --latency ${HOSTNAME}
