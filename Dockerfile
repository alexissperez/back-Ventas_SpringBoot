# --- ETAPA 1: COMPILACIÓN (Build Stage) ---
FROM maven:3.9-eclipse-temurin-17-alpine AS builder
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

# --- ETAPA 2: EJECUCIÓN EN PRODUCCIÓN (Production Stage) ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Usuario No-Root por seguridad (Exigencia IE1)
RUN addgroup -S springgroup && adduser -S springuser -G springgroup

COPY --from=builder /app/target/*.jar app.jar
RUN chown -R springuser:springgroup /app
USER springuser

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]