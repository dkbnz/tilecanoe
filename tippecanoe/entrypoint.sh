#!/bin/sh
currentChecksum=$(sha1sum locations.csv)
previousChecksum=$(sed "1q;d" metadata)

if [ "$currentChecksum" != "$previousChecksum" ]; then
  sleep 10
  # Recalculate tiles
  tippecanoe -zg -f -o /data/locations.mbtiles --cluster-distance=10 /data/locations.csv
  # Write current hash to metadata file
  sed -i "1s/.*/$currentChecksum/" metadata
else
  echo "No new locations."
fi
