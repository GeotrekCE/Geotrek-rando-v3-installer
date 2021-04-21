ARG VERSION

# ---- Get App and customize ----
FROM ghcr.io/geotrekce/geotrek-rando-v3/geotrek-rando-prebuild:${VERSION} AS customized-prebuild
COPY customization/. /app/customization/
COPY medias/. /app/src/public/medias/

# ---- Build----
FROM customized-prebuild AS customized-build
RUN yarn build

# ---- Release ----
FROM customized-build AS release
EXPOSE 80
ENTRYPOINT ["yarn", "start"]
