# Etapa de construcción (Build)
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
COPY src ./src
# Hacemos el ejecutable y compilamos ignorando tests para que sea más rápido
RUN chmod +x mvnw && ./mvnw clean package -DskipTests

# Etapa de ejecución (Run) - Usamos una imagen muy ligera
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/minimarket-backend-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080

# Forzamos los límites de memoria aquí para evitar que devore la RAM
ENTRYPOINT ["java", "-Xms128m", "-Xmx256m", "-jar", "app.jar"]
