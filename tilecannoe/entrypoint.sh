#!/bin/sh
set -e

PID=-1

update_tiles () {
  currentChecksum=$(sha1sum /data/locations.csv | tr -d '[:space:]')
  previousChecksum=$(head -n 1 /app/metadata | tr -d '[:space:]')

  if [ "$currentChecksum" != "$previousChecksum" ]; then
    echo -e "current='${currentChecksum}'"
    echo -e "previous='${previousChecksum}'"
    echo "Locations have changed, updating tiles."
    # SIGTERM
    if [ $PID != -1 ]; then
      echo "Stopping tileserver"
      kill -15 $PID
    fi
    # Recalculate tiles
    tippecanoe -zg -f -o /app/locations.mbtiles --cluster-distance=10 /data/locations.csv
    # Write current hash to metadata file
    echo "$currentChecksum" > /app/metadata
    echo "Starting tileserver"
    /bin/bash /usr/src/app/run.sh --config /app/config.json &
    PID=$!
  else
    echo "No new locations."
    if [ $PID = -1 ]; then
      echo "Starting tileserver"
      /bin/bash /usr/src/app/run.sh --config /app/config.json &
      PID=$!
    fi
  fi
}

touch /app/metadata

while :
do
  update_tiles
  sleep 30
done
