FROM docker.io/library/node:26.8.1-trixie-slim
# TODO: Remove util-linux upgrade once base image includes util-linux >= 2.41.5-0+deb13u1 (CVE-2026-53615)
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get -y --no-install-recommends --only-upgrade install bsdutils libblkid1 liblastlog2-2 libmount1 libsmartcols1 libuuid1 login mount util-linux \
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
