## Solution: Container Networking

### Root Cause

Multiple networking issues prevent services from communicating:
1. **Frontend can't reach backend**: Frontend is on `frontend-net`, backend is only on `backend-net`
2. **Wrong backend port**: `BACKEND_URL` uses port 8080, but backend listens on 3000
3. **Wrong service names**: Backend references `database` (should be `db`) and `cache` (should be `redis`)
4. **Redis isolated**: Redis is on `redis-net`, not shared with backend

### Fixed docker-compose.yml

```yaml
version: "3.8"

services:
  frontend:
    build: ./frontend
    ports:
      - "80:80"
    environment:
      - BACKEND_URL=http://backend:3000
    networks:
      - frontend-net
    depends_on:
      - backend

  backend:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - DATABASE_HOST=db
      - DATABASE_PORT=5432
      - DATABASE_USER=appuser
      - DATABASE_PASSWORD=secret123
      - DATABASE_NAME=myapp
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    networks:
      - frontend-net
      - backend-net
    depends_on:
      - db
      - redis

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=secret123
      - POSTGRES_DB=myapp
    networks:
      - backend-net
    volumes:
      - db-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    networks:
      - backend-net

networks:
  frontend-net:
    driver: bridge
  backend-net:
    driver: bridge

volumes:
  db-data:
```

### Verification

```bash
docker compose down
docker compose up -d
docker compose ps
curl http://localhost:80
docker compose logs backend | grep -i "connected"
```
