FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    stress-ng \
    procps \
    python3 \
    curl \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY stress-test.sh /app/stress-test.sh
RUN chmod +x /app/stress-test.sh

# BUG: No healthcheck configured — Docker won't detect when the container becomes unresponsive
# A healthcheck would at least mark the container as unhealthy even if the shim is dead

CMD ["/app/stress-test.sh"]
