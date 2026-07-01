# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /build

COPY go.mod ./
COPY main.go ./

# BUG: CGO_ENABLED is not set to 0, so the binary is dynamically linked
# It will require C libraries that don't exist in the scratch image
RUN go build -o server .

# Runtime stage
# BUG: Using scratch (empty image) with a dynamically linked binary
FROM scratch

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /build/server ./server

EXPOSE 8080

ENTRYPOINT ["/app/server"]
