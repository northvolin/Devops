#!/bin/bash

rm -rf .mvn mvnw mvnw.cmd

mvn -N io.takari:maven:wrapper



sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)


sudo docker network prune -f


sudo docker ps -a
sudo docker network ls


sudo docker-compose up --build -d
