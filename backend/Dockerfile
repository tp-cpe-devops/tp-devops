# Build
FROM maven:3.8.6-amazoncorretto-17 AS app
ENV MYAPP_HOME /opt/app
WORKDIR $MYAPP_HOME
COPY simpleapi/pom.xml .
COPY simpleapi/src ./src
RUN mvn package -DskipTests

# Run
FROM amazoncorretto:17
ENV MYAPP_HOME /opt/app
EXPOSE 8080
WORKDIR $MYAPP_HOME
COPY --from=app $MYAPP_HOME/target/*.jar $MYAPP_HOME/app.jar

ENTRYPOINT java -jar app.jar