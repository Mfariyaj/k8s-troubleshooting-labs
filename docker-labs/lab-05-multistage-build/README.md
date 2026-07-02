## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (builds and runs broken containers)
2. Check: `docker ps`, `docker logs <container>`
3. Test: Try `curl`, `docker exec`, check connectivity
4. Observe the failure and identify root cause
5. Fix the Dockerfile/docker-compose.yml and rebuild
6. Check `solution.md` if stuck

---

# Lab 05 - Multi-stage Build Failure

## Difficulty: ⭐⭐

## Scenario
A Go application uses a multi-stage Docker build. The build stage compiles successfully, but when the final minimal image runs the binary, it crashes immediately with a confusing "not found" error — even though the binary file clearly exists.

## What You'll See
When you run `./deploy.sh`:

Build succeeds, but container crashes:
```
$ docker run lab05-app
exec /app/server: no such file or directory
```

Or:
```
standard_init_linux.go:228: exec user process caused: no such file or directory
```

The binary exists but can't be executed!

## Hints
1. The "not found" error isn't about the binary itself - it's about something the binary NEEDS
2. Go binaries compiled with CGO enabled need C libraries (glibc/musl)
3. What base image is used in the final stage? Does it have those libraries?
4. How do you compile a Go binary that has no external dependencies?

## Troubleshooting Commands
```bash
# Build the image
docker build -t lab05-app .

# Try running it
docker run --rm lab05-app

# Check if the binary is actually there
docker run --rm --entrypoint /bin/sh lab05-app -c "ls -la /app/"

# Check what libraries the binary needs
docker run --rm lab05-app-builder ldd /app/server

# Check the base image
docker run --rm scratch  # This won't work - scratch has nothing!
```

## Resolution
The Go binary is compiled with CGO enabled (default), which creates a dynamically linked binary requiring glibc. The final stage uses `scratch` (empty image) or `alpine` (uses musl, not glibc). The dynamic linker can't be found, so Linux reports "not found."

**Fix options:**
1. Compile with `CGO_ENABLED=0` to create a static binary
2. Add `--ldflags '-extldflags "-static"'` to go build
3. Use a final image that has the required libraries (e.g., `debian:slim`)
