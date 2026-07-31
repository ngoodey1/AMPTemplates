# syntax=docker/dockerfile:1.7
ARG OSRM_VERSION=v26.5.0

FROM cubecoders/ampbase:debian AS builder
ARG OSRM_VERSION
USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential cmake git pkg-config ca-certificates \
    libboost-all-dev libbz2-dev liblua5.4-dev libprotobuf-dev protobuf-compiler \
    libstxxl-dev libxml2-dev libzip-dev libtbb-dev lua5.4 \
    libluabind-dev libosmpbf-dev libexpat1-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${OSRM_VERSION}" https://github.com/Project-OSRM/osrm-backend.git /src/osrm

WORKDIR /src/osrm
RUN cmake -S . -B build \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/osrm \
      -DENABLE_ASSERTIONS=OFF \
      -DBUILD_TOOLS=ON \
      -DBUILD_SHARED_LIBS=ON \
    && cmake --build build --parallel "$(nproc)" \
    && cmake --install build

FROM cubecoders/ampbase:debian
USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates curl \
    libboost-filesystem1.83.0 libboost-iostreams1.83.0 libboost-program-options1.83.0 \
    libboost-regex1.83.0 libboost-system1.83.0 libboost-thread1.83.0 \
    libbz2-1.0 liblua5.4-0 libprotobuf32 libstxxl1v5 libxml2 libzip4 \
    libtbb12 libosmpbf1 libexpat1 zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/osrm /opt/osrm

RUN chmod -R a+rX /opt/osrm \
    && /opt/osrm/bin/osrm-routed --version

USER amp
