#!/bin/bash

# Вход в Docker Hub
echo "iWauchok141" | docker login -u "digglega" --password-stdin

# Список сервисов
services=("session-service" "hotel-service" "payment-service" "loyalty-service" "report-service" "booking-service" "gateway-service" "database" "nginx")

# Сборка и загрузка каждого сервиса
for service in "${services[@]}"; do
  cd "./services/$services"
  docker build -t "digglega/$services:latest" .
  docker push "digglega/$services:latest"
  cd ../..
done
