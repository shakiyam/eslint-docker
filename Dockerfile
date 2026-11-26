FROM docker.io/library/node:26.13.1-trixie-slim
# TODO: Remove package upgrades once base image includes libzstd1 >= 1.5.7+dfsg-1+deb13u1 (CVE-2026-124851)
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get -y --no-install-recommends --only-upgrade install libzstd1 \
  && rm -rf /var/lib/apt/lists/*
COPY package.json package-lock.json /app/
WORKDIR /app
RUN npm ci --no-audit --no-fund \
  && rm -rf /root/.npm /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx
ENV NODE_PATH=/app/node_modules
ENV PATH=/app/node_modules/.bin:${PATH}
WORKDIR /work
# nobody:nogroup
USER 65534:65534
ARG SOURCE_COMMIT
LABEL org.opencontainers.image.revision=$SOURCE_COMMIT
ENTRYPOINT ["eslint"]
