# Intentionally bloated multi-stage build that leaves dangling intermediate layers
FROM ubuntu:22.04 AS base-deps
RUN apt-get update && apt-get install -y \
    curl wget git vim nano htop \
    python3 python3-pip nodejs npm \
    build-essential gcc g++ make \
    && rm -rf /var/lib/apt/lists/*

FROM base-deps AS build-stage
WORKDIR /app
# Copy everything (no .dockerignore, includes .git, node_modules, logs)
COPY . .
RUN echo "Building application artifacts..." && \
    dd if=/dev/urandom of=/app/build-artifact-1.bin bs=1M count=50 && \
    dd if=/dev/urandom of=/app/build-artifact-2.bin bs=1M count=50

FROM ubuntu:22.04 AS runtime
WORKDIR /app
# BUG: Copies entire build context including 100MB of artifacts not needed at runtime
COPY --from=build-stage /app /app
# Application that generates massive stdout/stderr logging
COPY log-generator.sh /app/log-generator.sh
RUN chmod +x /app/log-generator.sh
CMD ["/app/log-generator.sh"]
