FROM maptiler/tileserver-gl

# Update repos and install dependencies
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install build-essential libsqlite3-dev zlib1g-dev

# Clone tippecanoe
WORKDIR /tippecanoe
RUN git clone https://github.com/mapbox/tippecanoe.git .

# Build, install & test tippecanoe
RUN make \
  && make install \
  && make test

# Remove source code post install
WORKDIR /data
RUN rm -rf /tippecanoe

COPY config.json /data/

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]
