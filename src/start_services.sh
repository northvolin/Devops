#!/bin/bash

# Function to check if Docker daemon is running
check_docker() {
    if ! sudo systemctl is-active --quiet docker; then
        echo "Docker is not running. Starting Docker..."
        sudo systemctl start docker
        if [ $? -ne 0 ]; then
            echo "Failed to start Docker. Exiting."
            exit 1
        fi
    fi
}

# Function to install Vagrant
install_vagrant() {
    echo "Installing Vagrant..."
    if ! command -v vagrant &> /dev/null; then
        echo "Vagrant is not installed. Installing Vagrant..."
        wget https://releases.hashicorp.com/vagrant/2.3.4/vagrant_2.3.4_linux_amd64.zip -O vagrant.zip
        unzip vagrant.zip
        sudo mv vagrant /usr/local/bin/
        rm vagrant.zip
        echo "Vagrant installed successfully."
    else
        echo "Vagrant is already installed."
    fi
}

# Function to install VirtualBox
install_virtualbox() {
    echo "Installing VirtualBox..."
    if ! command -v vboxmanage &> /dev/null; then
        echo "VirtualBox is not installed. Installing VirtualBox..."
        sudo apt update
        sudo apt install -y virtualbox
        echo "VirtualBox installed successfully."
    else
        echo "VirtualBox is already installed."
    fi
}

# Function to setup Vagrant
setup_vagrant() {
    echo "Setting up Vagrant..."
    if [ ! -f Vagrantfile ]; then
        vagrant init
        vagrant box add ubuntu/bionic64
        vagrant up
    else
        echo "Vagrant is already set up."
    fi
}

# Checking Docker status
echo "Checking Docker status..."
check_docker

# Stopping all Docker containers
echo "Stopping all running containers and removing Docker artifacts..."
sudo docker-compose down || true
sudo docker rm -f $(sudo docker ps -aq) || true
sudo docker rmi -f $(sudo docker images -q) || true
sudo docker network rm local-network src_local-network || true
sudo docker network prune -f
sudo docker system prune -f

# Releasing ports
echo "Releasing necessary ports..."
ports=(22 2222 2200 2201 2202 2203 2204 5672 5433 80 8080 8081 8082 8083 8084 8085 8086 15672 7946 2377 4789)
for port in "${ports[@]}"; do
  echo "Checking port $port..."
  pids=$(sudo lsof -t -i:$port)
  if [ -n "$pids" ]; then
    sudo kill -9 $pids
  fi
done

# Restart PostgreSQL
echo "Restarting PostgreSQL..."
sudo systemctl stop postgresql || sudo service postgresql stop
sudo systemctl restart postgresql

# Create local network
echo "Creating local network..."
sudo docker network create local-network

# Build and start Docker services
echo "Building and starting services with Docker Compose..."
sudo docker-compose up --build -d

# Waiting for services to start
echo "Waiting for services to start..."
sleep 30

# Run Postman tests
echo "Checking for Newman and running Postman tests if installed..."
if command -v newman &> /dev/null; then
  if [ -f application_tests.postman_collection.json ]; then
    newman run application_tests.postman_collection.json
  else
    echo "Postman collection application_tests.postman_collection.json not found."
  fi
else
  echo "Newman is not installed. Skipping Postman tests."
fi

# Display Docker container status
echo "Displaying Docker container status..."
sudo docker-compose ps

# Docker login
echo "Logging into Docker Hub..."
DOCKER_USERNAME="digglega"
DOCKER_PASSWORD="${DOCKER_PASSWORD}"

if [ -z "$DOCKER_PASSWORD" ]; then
  echo "Docker password not set. Please set the DOCKER_PASSWORD environment variable."
  exit 1
fi

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
if [ $? -ne 0 ]; then
  echo "Docker login failed. Exiting."
  exit 1
fi

# Docker Scout
echo "Running Docker Scout..."
docker scout quickview

# Tagging and pushing Docker images
echo "Tagging and pushing Docker images..."
services=("session-service" "hotel-service" "payment-service" "loyalty-service" "report-service" "booking-service" "gateway-service")
for service in "${services[@]}"; do
  echo "Tagging and pushing $service..."
  docker tag "src_$service" "digglega/$service:latest"
  docker push "digglega/$service:latest"
done

# Open Docker Desktop
echo "Opening Docker Desktop..."
if command -v docker-desktop &> /dev/null; then
  docker-desktop
else
  echo "Docker Desktop is not installed or not found in PATH."
fi

# Install Vagrant and VirtualBox
install_vagrant
install_virtualbox

# Setup Vagrant
setup_vagrant
