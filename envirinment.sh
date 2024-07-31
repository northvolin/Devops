#!/bin/bash

# Функция для проверки и ожидания разблокировки dpkg
wait_for_dpkg_unlock() {
  while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "Waiting for other apt-get processes to finish..."
    sleep 5
  done
}

# Удаление старого репозитория erlang-solutions, если он есть
sudo rm /etc/apt/sources.list.d/erlang-solutions.list || true

# Обновление и установка основных пакетов
wait_for_dpkg_unlock
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y ca-certificates curl gnupg apt-transport-https software-properties-common wget

# Удаление старых версий Docker, если они есть
wait_for_dpkg_unlock
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# Удаление старых пакетов
sudo apt autoremove -y

# Настройка репозитория Docker и установка Docker
wait_for_dpkg_unlock
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
wait_for_dpkg_unlock
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker && sudo systemctl enable docker

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose && docker-compose --version

# Добавление репозитория PostgreSQL и установка PostgreSQL
wait_for_dpkg_unlock
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
wait_for_dpkg_unlock
sudo apt-get update && sudo apt-get install -y postgresql postgresql-contrib

# Настройка базы данных PostgreSQL
sudo -u postgres psql -c "CREATE USER postgres WITH PASSWORD '1';" || true
sudo -u postgres psql -c "CREATE DATABASE hotels;" || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE hotels TO postgres;" || true

# Установка RabbitMQ
wait_for_dpkg_unlock
sudo apt-get install -y curl gnupg apt-transport-https
curl -fsSL https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey | sudo tee /etc/apt/trusted.gpg.d/rabbitmq.asc
sudo sh -c 'echo "deb https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/rabbitmq.list'
wait_for_dpkg_unlock
sudo apt-get update && sudo apt-get install -y rabbitmq-server

# Unmask and enable RabbitMQ service
sudo systemctl unmask rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server

# Установка Node.js и npm
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

# Установка Newman
sudo npm install -g newman

# Установка Maven
sudo apt-get install -y maven

# Установка Portainer
sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# Установка Nginx
wait_for_dpkg_unlock
sudo apt-get update && sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Установка JDK
wait_for_dpkg_unlock
sudo apt-get install -y openjdk-11-jdk

# Установка Git
wait_for_dpkg_unlock
sudo apt-get install -y git

# Установка основных утилит для сборки и разработки
wait_for_dpkg_unlock
sudo apt-get install -y build-essential libssl-dev

# Установка пакетов для работы с API и сетями
wait_for_dpkg_unlock
sudo apt-get install -y net-tools iputils-ping telnet


# Установка Portainer
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# Установка Docker Desktop
# Установка зависимостей для Docker Desktop
wait_for_dpkg_unlock
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Настройка репозитория Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Скачивание и установка Docker Desktop
DOCKER_DESKTOP_URL="https://desktop.docker.com/linux/main/amd64/149282/docker-desktop-4.30.0-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64&_gl=1*1y0ph7w*_ga*MTMzMDYxNDI5OC4xNzE3NTE4OTY4*_ga_XJWPQMJYHQ*MTcxNzUzODU2My4yLjEuMTcxNzUzODgyMS40OS4wLjA."
wget -O docker-desktop.deb "$DOCKER_DESKTOP_URL"
sudo apt-get update
sudo apt-get install -y ./docker-desktop.deb


echo "Environment setup complete."
