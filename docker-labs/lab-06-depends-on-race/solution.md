## Solution: Depends-On Race Condition

### Root Cause

`depends_on` only waits for the container to *start*, not for the service to be *ready*. PostgreSQL takes several seconds to initialize (especially with init scripts). The Flask app starts immediately, tries to connect, and fails because PostgreSQL isn't accepting connections yet.

### Step-by-Step Fix

1. Add a `healthcheck` to the `db` service that tests PostgreSQL readiness
2. Change `depends_on` to use `condition: service_healthy`

### Fixed docker-compose.yml

```yaml
version: "3.8"

services:
  app:
    build: .
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://appuser:secret123@db:5432/myapp
      - FLASK_ENV=production
    depends_on:
      db:
        condition: service_healthy
    restart: "no"

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=secret123
      - POSTGRES_DB=myapp
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d myapp"]
      interval: 5s
      timeout: 5s
      retries: 10
      start_period: 10s
    volumes:
      - pg-data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init.sql

volumes:
  pg-data:
```

### Verification

```bash
docker compose down -v
docker compose up -d
docker compose ps
# DB should show "healthy" before app starts
docker compose logs db | grep "ready to accept"
docker compose logs app
curl http://localhost:5000
```
