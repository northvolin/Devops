# Используйте подходящий базовый образ
FROM openjdk:11-jdk-slim

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы и папки проекта в контейнер
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Делаем скрипт Maven Wrapper исполняемым
RUN chmod +x mvnw

# Запускаем команду для скачивания зависимостей и упаковки проекта
RUN ./mvnw dependency:go-offline

# Открываем порт для приложения
EXPOSE 8083

# Запускаем приложение
CMD ["./mvnw", "spring-boot:run"]
