#Используем официальный образ PostgreSQL
FROM postgres:latest

# Устанавливаем переменные окружения для PostgreSQL
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=1
ENV POSTGRES_DB=app_db

#Копируем файл инициализации базы данных
COPY init.sql /docker-entrypoint-initdb.d/