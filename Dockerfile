# --- PRODUCTION_BUILD_V3.0 ---
FROM maven:3.9-eclipse-temurin-21-slim AS build
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -S prepedge && adduser -S prepedge -G prepedge
COPY --from=build /build/target/*.jar app.jar
RUN chown -R prepedge:prepedge /app
USER prepedge
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"
ENV SPRING_PROFILES_ACTIVE=prod
EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
