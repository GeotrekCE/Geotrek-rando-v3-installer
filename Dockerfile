ARG VERSION=latest

# ---- Base Node ----
FROM node:12-alpine3.12 AS base
WORKDIR /app

# ---- Get App and customize ----
FROM ghcr.io/geotrekce/geotrek-rando-v3/geotrek-rando-prebuild:${VERSION} AS customizedPrebuild
COPY customization/. /app/customization/

# ---- Dependencies ----
FROM customizedPrebuild AS dependencies
RUN yarn

# ---- Copy customization/Build----
FROM dependencies AS customizedBuild
RUN yarn build

#---- Prod Dependencies ----
FROM customizedPrebuild AS prodDependencies
RUN yarn --production

# ---- Release ----
FROM base AS release
COPY --from=prodDependencies /app/package.json ./
COPY --from=prodDependencies /app/yarn.lock ./
COPY --from=prodDependencies /app/node_modules ./node_modules
COPY --from=customizedBuild /app/src ./src
COPY --from=customizedBuild /app/next.config.js ./
COPY --from=customizedBuild /app/cache.js ./
COPY --from=customizedBuild /app/config ./config
EXPOSE 80
CMD ["yarn", "start"]
