# Build stage: use Maven with JDK 17 Alpine image
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Copy Maven files first to cache dependency downloads
COPY pom.xml .
COPY src ./src

# Build executable jar without tests for faster build
RUN mvn -B -DskipTests package

# Runtime stage: use lightweight JRE image
FROM eclipse-temurin:17-jre-alpine AS runtime
WORKDIR /app

# Copy jar from build stage
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8081

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
