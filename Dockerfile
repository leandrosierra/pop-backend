FROM maven:3.9-eclipse-temurin-8 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn package -DskipTests -B

FROM tomcat:9.0-jre8
# psql client to apply the SQL schema + seed at startup (schema owned by SQL/, not Hibernate)
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*
RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
COPY SQL/DB_CREATION.sql /docker-init/DB_CREATION.sql
COPY SQL/Init_script_pg.sql /docker-init/Init_script_pg.sql
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN sed -i 's/\r$//' /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.sh"]
