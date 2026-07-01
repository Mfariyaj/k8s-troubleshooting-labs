FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    procps \
    htop \
    strace \
    iproute2 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY worker.sh /app/worker.sh
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/worker.sh /app/entrypoint.sh

# BUG: No TINI or dumb-init as PID 1
# The shell script runs as PID 1, but bash doesn't reap adopted zombies
# This means orphaned grandchildren become permanent zombies
ENTRYPOINT ["/app/entrypoint.sh"]
