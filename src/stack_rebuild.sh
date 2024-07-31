#!/bin/bash

# Убедитесь, что скрипт запускается от имени пользователя с соответствующими правами
if [ "$(id -u)" -ne "0" ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Удаляем старый стек
echo "Removing old stack..."
docker stack rm my_stack || { echo "Failed to remove my_stack"; exit 1; }

# Ожидаем завершения удаления стека
echo "Waiting for stack removal to complete..."
sleep 10

# Проверяем, существует ли сеть и удаляем, если существует
if docker network inspect my_stack_network >/dev/null 2>&1; then
  echo "Removing old network..."
  docker network rm my_stack_network || { echo "Failed to remove my_stack_network"; exit 1; }
fi

# Создаем новую сеть
echo "Creating new network..."
docker network create --driver overlay my_stack_network || { echo "Failed to create my_stack_network"; exit 1; }

# Проверяем наличие старой конфигурации и удаляем, если существует
if docker config inspect nginx_config >/dev/null 2>&1; then
  echo "Removing old nginx_config..."
  docker config rm nginx_config || { echo "Failed to remove nginx_config"; exit 1; }
fi

# Создаем новую конфигурацию
echo "Creating new nginx_config..."
docker config create nginx_config ./services/nginx/nginx.conf || { echo "Failed to create nginx_config"; exit 1; }

# Разворачиваем новый стек
echo "Deploying new stack..."
docker stack deploy -c docker-compose.yml my_stack || { echo "Failed to deploy my_stack"; exit 1; }

# Проверяем состояние стека
echo "Checking stack services..."
docker stack ps my_stack || { echo "Failed to check stack services"; exit 1; }

# Проверяем список сервисов
echo "Listing Docker services..."
docker service ls || { echo "Failed to list Docker services"; exit 1; }

# Проверяем конфигурацию Nginx
echo "Testing nginx configuration..."
docker run --rm -v $(pwd)/services/nginx/nginx.conf:/etc/nginx/nginx.conf nginx:latest nginx -t || { echo "Nginx configuration test failed"; exit 1; }

echo "Script completed successfully."
