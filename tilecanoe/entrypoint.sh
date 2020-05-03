#!/bin/sh
set -e
PID=-1

# Colour logs before printing to stdout
log () {
  while read data;
  do
    echo -e "\033[${1}m[${2}]\033[0m $data";
  done;
}

# Check if locations.csv has changed
# If so, stop server, recalculate tiles then restart server.
update_tiles () {
  touch /app/metadata
  previousChecksum=$(head -n 1 /app/metadata | tr -d '[:space:]')
  currentChecksum=$(sha1sum /data/locations.csv | tr -d '[:space:]')

  if [ "$currentChecksum" != "$previousChecksum" ]; then
    echo "[$(date +"%Y-%m-%dT%H:%M:%SZ")] Locations changed, updating tiles." | log '0;32' 'tippecanoe'
    if [ $PID != -1 ]; then
      echo "Stopping tileserver" | log '0;32' 'tippecanoe'
      kill -15 $PID
    fi
    # Recalculate tiles
    tippecanoe -zg -f -o /app/locations.mbtiles /data/locations.csv | log '0;32' 'tippecanoe'
    # Write current hash to metadata file
    echo "$currentChecksum" > /app/metadata
    echo "Starting tileserver" | log '0;32' 'tippecanoe'
    /bin/bash /usr/src/app/run.sh --config /app/config.json | log '0;33' 'tileserver' &
    PID=$(jobs -p) # Capture PID to kill later
  else
    echo "[$(date +"%Y-%m-%dT%H:%M:%SZ")] No new locations." | log '0;32' 'tippecanoe'
    if [ $PID = -1 ]; then
      echo "Starting tileserver" | log '0;32' 'tippecanoe'
      /bin/bash /usr/src/app/run.sh --config /app/config.json | log '0;33' 'tileserver' &
      PID=$(jobs -p) # Capture PID to kill later
    fi
  fi
}

while :
do
  update_tiles
  sleep 3600 # Wait an hour before checking for new locations.
done
