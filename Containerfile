ARG BASE_VERSION=15
FROM ghcr.io/daemonless/arr-base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
ARG PACKAGES="lidarr chromaprint"
ARG LIDARR_BRANCH="master"
ARG UPSTREAM_URL="https://lidarr.servarr.com/v1/update/${LIDARR_BRANCH}/changes?os=bsd&runtime=netcore"
ARG DOWNLOAD_URL="https://lidarr.servarr.com/v1/update/${LIDARR_BRANCH}/updatefile?os=bsd&arch=x64&runtime=netcore"
ARG UPSTREAM_JQ=".[0].version"
ARG HEALTHCHECK_ENDPOINT="http://localhost:8686/ping"

ENV HEALTHCHECK_URL="${HEALTHCHECK_ENDPOINT}"

LABEL org.opencontainers.image.title="Lidarr" \
    org.opencontainers.image.description="Lidarr music management on FreeBSD" \
    org.opencontainers.image.source="https://github.com/daemonless/lidarr" \
    org.opencontainers.image.url="https://lidarr.audio/" \
    org.opencontainers.image.documentation="https://wiki.servarr.com/lidarr" \
    org.opencontainers.image.licenses="GPL-3.0-only" \
    org.opencontainers.image.vendor="daemonless" \
    org.opencontainers.image.authors="daemonless" \
    io.daemonless.port="8686" \
    io.daemonless.arch="${FREEBSD_ARCH}" \
    io.daemonless.volumes="/music,/downloads" \
    org.freebsd.jail.allow.mlock="required" \
    io.daemonless.category="Media Management" \
    io.daemonless.upstream-url="${UPSTREAM_URL}" \
    io.daemonless.upstream-jq="${UPSTREAM_JQ}" \
    io.daemonless.healthcheck-url="${HEALTHCHECK_ENDPOINT}" \
    io.daemonless.packages="${PACKAGES}"

# Install Lidarr and chromaprint (audio fingeprinting)
RUN pkg update && \
    pkg install -y \
    ${PACKAGES} && \
    pkg clean -ay && \
    rm -rf /var/cache/pkg/* /var/db/pkg/repos/*

# Download and install Lidarr
RUN LIDARR_VERSION=$(fetch -qo - "${UPSTREAM_URL}" | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4) && \
    install-arr.sh "lidarr" "Lidarr" "$LIDARR_VERSION" "${DOWNLOAD_URL}" "${LIDARR_BRANCH}"

# Copy service definition and init scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /etc/services.d/lidarr/run /etc/cont-init.d/* 2>/dev/null || true

EXPOSE 8686
VOLUME /config


