# B-1404: production image. Build:  docker build -t tranix-backend .
# Run:  docker run -p 8080:8080 -e SPRING_PROFILES_ACTIVE=prod -e DB_HOST=... -e DB_PASSWORD=... -e JWT_SECRET=... tranix-backend
# Health for the load balancer: GET /actuator/health/liveness and /actuator/health/readiness
FROM eclipse-temurin:21-jdk AS build
WORKDIR /src
COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw -q -B dependency:go-offline
COPY src src
RUN ./mvnw -q -B -DskipTests package && cp target/tranix-*.jar /app.jar

FROM eclipse-temurin:21-jre
RUN useradd --system --uid 10001 tranix && mkdir -p /data/files && chown tranix /data/files
USER tranix
WORKDIR /app
COPY --from=build /app.jar app.jar
ENV FILES_DIR=/data/files JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError"
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
