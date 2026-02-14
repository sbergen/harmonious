ARG TARGETPLATFORM=linux/arm64/v8
ARG ERLANG_VERSION=28.3
ARG GLEAM_VERSION=v1.14.0

# Gleam stage
FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-scratch AS gleam

ARG TARGETPLATFORM

# Build stage
FROM --platform=${TARGETPLATFORM} erlang:${ERLANG_VERSION}-alpine AS build
RUN apk add --no-cache git
COPY --from=gleam /bin/gleam /bin/gleam
COPY . /app/
RUN cd /app && gleam export erlang-shipment

# Final stage
FROM --platform=${TARGETPLATFORM} erlang:${ERLANG_VERSION}-alpine
COPY --from=build /app/build/erlang-shipment /app
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
