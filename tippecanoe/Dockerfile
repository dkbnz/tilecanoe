# Start from alpine
FROM alpine:latest

# Update repos and install dependencies
RUN apk update \
    && apk add --virtual build-dependencies \
        build-base \
        gcc \
        perl \
        bash \
        git \
        sqlite-libs \
        sqlite-dev \
        libgcc \
        libstdc++ \
        zlib-dev \
        libc6-compat

# Clone tippecanoe
RUN git clone https://github.com/mapbox/tippecanoe.git
WORKDIR /tippecanoe/

# Build, install & test tippecanoe
RUN make \
  && make install \
  && make test

# Remove source code post install
WORKDIR /
RUN rm -rf /tippecanoe

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
