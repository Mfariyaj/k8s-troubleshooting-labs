FROM node:20-alpine

WORKDIR /app

COPY package.json ./
RUN npm install --production

COPY server.js ./

# BUG 1: curl is not installed in alpine (need to `apk add curl`)
# BUG 2: Wrong port - app runs on 3000, but healthcheck hits 8080
# BUG 3: Wrong path - app has /health, but healthcheck hits /healthz
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/healthz || exit 1

EXPOSE 3000

CMD ["node", "server.js"]
