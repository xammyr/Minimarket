# Etapa de construcción (Build)
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml ./
COPY src ./src
# Hacemos el ejecutable y compilamos ignorando tests para que sea más rápido
RUN mvn clean package -DskipTests

# Etapa de ejecución (Run) - Usamos una imagen muy ligera
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080

# Forzamos los límites de memoria aquí para evitar que devore la RAM
ENTRYPOINT ["java", "-Xms128m", "-Xmx256m", "-jar", "app.jar"]
