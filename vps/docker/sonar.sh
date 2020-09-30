#!/bin/bash

docker run -d --name sonarqube \
  --restart unless-stopped \
  -p 127.0.0.1:9000:9000 \
  --network postgres \
  -e SONAR_JDBC_URL=jdbc:postgresql://postgres:5432/sonardb \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=rtp2Az3boWjGbBFT4hq8 \
  -v /var/lib/sonarqube/data:/opt/sonarqube/data \
  -v /var/lib/sonarqube/extensions:/opt/sonarqube/extensions \
  -v /var/lib/sonarqube/logs:/opt/sonarqube/logs \
  sonarqube:community

