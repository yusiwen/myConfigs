#!/bin/bash

docker run -d --name sonar \
    --restart unless-stopped \
    -p 9000:9000 \
    -e SONAR_JDBC_URL=jdbc:postgresql://172.19.190.81:5432/sonardb \
    -e SONAR_JDBC_USERNAME=sonar \
    -e SONAR_JDBC_PASSWORD=XXXX \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    -v sonarqube_logs:/opt/sonarqube/logs \
    sonarqube:community

