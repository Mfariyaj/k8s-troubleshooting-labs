FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY App.java ./

# Compile in same image for simplicity (not ideal for production)
RUN apk add --no-cache openjdk17 && \
    javac App.java && \
    apk del openjdk17

# BUG: -Xmx512m requests 512MB heap but container only has 256MB
ENTRYPOINT ["java", "-Xmx512m", "-Xms256m", "App"]
