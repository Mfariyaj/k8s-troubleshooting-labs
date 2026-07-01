# Lab 06 - Depends_on Not Waiting for Readiness

## Difficulty: ⭐⭐⭐

## Scenario
A Python Flask application depends on PostgreSQL. The `docker-compose.yml` has `depends_on: db` configured, but the app still crashes on startup because it tries to connect to the database before PostgreSQL has finished initializing.

## What You'll See
When you run `./deploy.sh`:

```
app_1  | Connecting to database at db:5432...
app_1  | psycopg2.OperationalError: could not connect to server: Connection refused
app_1  |     Is the server running on host "db" (172.18.0.2) and accepting
app_1  |     TCP/IP connections on port 5432?
app_1  | Application crashed! Database not ready.
db_1   | PostgreSQL init process complete; ready for start up.
db_1   | LOG:  database system is ready to accept connections
```

Notice: the app crashes BEFORE the database logs "ready to accept connections."

## Hints
1. `depends_on` only waits for the container to START, not for the service inside to be READY
2. How can you tell Docker Compose to wait until PostgreSQL is actually accepting connections?
3. What's the difference between `depends_on` with and without `condition:`?
4. How would you add a healthcheck to the database service?

## Troubleshooting Commands
```bash
# Watch the startup order
docker compose up

# Check if DB is ready
docker compose exec db pg_isready -U appuser

# Check health status
docker compose ps

# View startup timing
docker compose logs --timestamps
```

## Resolution
`depends_on` without a condition only ensures container start order, not readiness. PostgreSQL takes several seconds to initialize.

**Fix:** Add a healthcheck to the db service and use `depends_on` with `condition: service_healthy`:

```yaml
db:
  image: postgres:15-alpine
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U appuser -d myapp"]
    interval: 5s
    timeout: 5s
    retries: 5

app:
  depends_on:
    db:
      condition: service_healthy
```
