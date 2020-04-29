#!/bin/sh
currentChecksum=$(sha1sum /data/locations.csv)
previousChecksum=$(sed "1q;d" /data/metadata)

if [ "$currentChecksum" != "$previousChecksum" ]; then
  sleep 10
  # Recalculate tiles
  tippecanoe -zg -f -o /data/locations.mbtiles --cluster-distance=10 /data/locations.csv
  # Write current hash to metadata file
  tilesChecksum=$(sha1sum /data/locations.mbtiles)
  sed -i "1s/.*/$currentChecksum/" metadata
  sed -i "2s/.*/$tilesChecksum/" metadata
else
  echo "No new locations."
fi
