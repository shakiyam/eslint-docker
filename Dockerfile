FROM docker.io/library/node:26.10.0-trixie-slim
# TODO: Remove package upgrades once base image includes gzip >= 1.13-1+deb13u1 (CVE-2026-41992),
# libpcre2-8-0 >= 10.46-1~deb13u2 (CVE-2026-86145), libsqlite3-0 >= 3.46.1-7+deb13u2 (CVE-2026-11822),
# and perl-base >= 5.40.1-6+deb13u1 (CVE-2026-13221)
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get -y --no-install-recommends --only-upgrade install gzip libpcre2-8-0 libsqlite3-0 perl-base \
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
