FROM node:20-alpine

WORKDIR /app

# BUG: Copying ALL source code before npm install
# This means ANY change to ANY file invalidates the npm install cache
COPY . .

RUN npm install --production

EXPOSE 8080

CMD ["node", "src/app.js"]
