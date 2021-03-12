ARG VERSION=latest

# ---- Get App and customize ----
FROM ghcr.io/geotrekce/geotrek-rando-v3/geotrek-rando-prebuild:${VERSION} AS customized-prebuild
COPY customization/. /app/customization/

# ---- Build----
FROM customized-prebuild AS customized-build
RUN yarn build

# ---- Release ----
FROM customized-build AS release
EXPOSE 80
ENTRYPOINT ["yarn", "start"]
