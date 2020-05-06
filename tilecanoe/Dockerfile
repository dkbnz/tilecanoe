FROM debian:buster-slim as builder

WORKDIR /build

# Update repos, install dependencies and build tippecanoe
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install build-essential libsqlite3-dev zlib1g-dev git \
  && git clone https://github.com/mapbox/tippecanoe.git . \
  && make tippecanoe

FROM maptiler/tileserver-gl

COPY --from=builder /build/tippecanoe /usr/local/bin/
COPY /app/ /app/

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
