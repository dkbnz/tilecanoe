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

# Update data shown in top left of map
update_metadata () {
  map_generated=$(date +'%s') # Get current date (time map generated)
  num_points=$(wc -l /data/locations.csv | awk '{ print $1-1 }') # Count total points in file
  printf '{"generatedAgo":"%s","points":"%s"}\n' \
  "$map_generated" "$num_points" > /usr/src/app/public/resources/metadata.json
}

# Check if locations.csv has changed
# If so, stop server, recalculate tiles then restart server.
update_tiles () {
  touch /app/metadata
  previous_checksum=$(head -n 1 /app/metadata | tr -d '[:space:]')
  current_checksum=$(sha1sum /data/locations.csv | tr -d '[:space:]')

  if [ "$current_checksum" != "$previous_checksum" ]; then
    echo "[$(date +"%Y-%m-%dT%H:%M:%SZ")] Locations changed, updating tiles." | log '0;32' 'tippecanoe'

    # Recalculate tiles
    tippecanoe -zg -f -o /app/locations_temp.mbtiles /data/locations.csv | log '0;32' 'tippecanoe'

    if [ $PID != -1 ]; then
      echo "Stopping tileserver" | log '0;32' 'tippecanoe'
      kill -15 $PID
      wait $PID
    fi

    mv -f /app/locations_temp.mbtiles /app/locations.mbtiles

    echo "Starting tileserver" | log '0;32' 'tippecanoe'
    /bin/bash /usr/src/app/run.sh --config /app/config.json | log '0;33' 'tileserver' &
    PID=$(jobs -p) # Capture PID to kill later

    update_metadata
    # Write current hash to metadata file
    echo "$current_checksum" > /app/metadata
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
