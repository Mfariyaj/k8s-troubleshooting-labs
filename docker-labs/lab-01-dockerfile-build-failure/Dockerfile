# BUG 1: "alphine" is a typo - should be "alpine"
FROM node:22-alphine

WORKDIR /app

COPY package*.json ./

# BUG 2: Missing backslash at end of line - breaks multi-line RUN
RUN npm install
    && npm cache clean --force \
    && rm -rf /tmp/*

# BUG 3: src/config/ doesn't exist in the build context
COPY src/config/ ./config/
COPY src/ ./src/

EXPOSE 3000

CMD ["node", "src/index.js"]
