FROM maven:3.9.1-eclipse-temurin-11 as maven
WORKDIR  /usr/src/topnotchspringapp
COPY top-notch-spring-boot-application /usr/src/topnotchspringapp/top-notch-spring-boot-application
COPY top-notch-spring-boot-dependency-management /usr/src/topnotchspringapp/top-notch-spring-boot-dependency-management
COPY pom.xml /usr/src/topnotchspringapp
RUN mvn clean install

FROM eclipse-temurin:11-jre as builder
WORKDIR application
COPY --from=maven /usr/src/topnotchspringapp/top-notch-spring-boot-application/target/*.jar application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM eclipse-temurin:11-jre
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]