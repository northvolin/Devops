#!/bin/bash

# Function to check and wait for dpkg to be unlocked
wait_for_dpkg_unlock() {
  while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
    echo "Waiting for other apt-get processes to finish..."
    sleep 5
  done
}

# Remove old Erlang Solutions repository if it exists
sudo rm /etc/apt/sources.list.d/erlang-solutions.list || true

# Update and install essential packages
wait_for_dpkg_unlock
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y ca-certificates curl gnupg apt-transport-https software-properties-common wget

# Remove old Docker versions if they exist
wait_for_dpkg_unlock
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# Remove old packages
sudo apt autoremove -y

# Setup Docker repository and install Docker
wait_for_dpkg_unlock
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Remove duplicate Docker repository entries
sudo rm /etc/apt/sources.list.d/archive_uri-https_download_docker_com_linux_ubuntu-jammy.list || true

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
wait_for_dpkg_unlock
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker && sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose && docker-compose --version

# Add PostgreSQL repository and install PostgreSQL
wait_for_dpkg_unlock
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
wait_for_dpkg_unlock
sudo apt-get update && sudo apt-get install -y postgresql postgresql-contrib

# Setup PostgreSQL database
sudo -u postgres psql -c "CREATE USER postgres WITH PASSWORD '1';" || true
sudo -u postgres psql -c "CREATE DATABASE hotels;" || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE hotels TO postgres;" || true

# Install RabbitMQ
wait_for_dpkg_unlock
sudo apt-get install -y curl gnupg apt-transport-https
curl -fsSL https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey | sudo tee /etc/apt/trusted.gpg.d/rabbitmq.asc
sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
deb https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/ $(lsb_release -cs) main
deb-src https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/ $(lsb_release -cs) main
EOF
wait_for_dpkg_unlock
sudo apt-get update
sudo apt-get install -y rabbitmq-server

# Unmask, enable, and start RabbitMQ service
sudo systemctl unmask rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
wait_for_dpkg_unlock
sudo apt-get install -y nodejs

# Install Newman
sudo npm install -g newman

# Install Maven
wait_for_dpkg_unlock
sudo apt-get install -y maven

# Install Portainer
sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# Install Nginx
wait_for_dpkg_unlock
sudo apt-get update && sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Install JDK
wait_for_dpkg_unlock
sudo apt-get install -y openjdk-11-jdk

# Install Git
wait_for_dpkg_unlock
sudo apt-get install -y git

# Install essential build and development utilities
wait_for_dpkg_unlock
sudo apt-get install -y build-essential libssl-dev

# Install packages for working with APIs and networks
wait_for_dpkg_unlock
sudo apt-get install -y net-tools iputils-ping telnet

# Install Docker Desktop
wait_for_dpkg_unlock
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Setup Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Download and install Docker Desktop
DOCKER_DESKTOP_URL="https://desktop.docker.com/linux/main/amd64/149282/docker-desktop-4.30.0-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64&_gl=1*1y0ph7w*_ga*MTMzMDYxNDI5OC4xNzE3NTE4OTY4*_ga_XJWPQMJYHQ*MTcxNzUzODU2My4yLjEuMTcxNzUzODgyMS40OS4wLjA."
wget -O docker-desktop.deb "$DOCKER_DESKTOP_URL"
wait_for_dpkg_unlock
sudo apt-get install -y ./docker-desktop.deb

echo "Environment setup complete."
