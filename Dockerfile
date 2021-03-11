ARG VERSION=latest

# ---- Base Node ----
FROM node:12-alpine3.12 AS base
WORKDIR /app

# ---- Get App and customize ----
FROM ghcr.io/geotrekce/geotrek-rando-v3/geotrek-rando-prebuild:${VERSION} AS customized-prebuild
COPY customization/. /app/customization/

# ---- Dependencies ----
FROM customized-prebuild AS dependencies
RUN yarn

# ---- Copy customization/Build----
FROM dependencies AS customized-build
RUN yarn build

#---- Prod Dependencies ----
FROM customized-prebuild AS prod-dependencies
RUN yarn --production

# ---- Release ----
FROM base AS release
COPY --from=prod-dependencies /app/package.json ./
COPY --from=prod-dependencies /app/yarn.lock ./
COPY --from=prod-dependencies /app/node_modules ./node_modules
COPY --from=customized-build /app/src ./src
COPY --from=customized-build /app/next.config.js ./
COPY --from=customized-build /app/cache.js ./
COPY --from=customized-build /app/config ./config
COPY --from=customized-build /app/customization ./customization
EXPOSE 80
CMD ["yarn", "start"]
