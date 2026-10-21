
FROM maven:3.9-eclipse-temurin-17

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn -B clean compile

EXPOSE 8080

CMD ["mvn", "-B", "exec:java"]
