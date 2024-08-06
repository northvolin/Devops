FROM maven:3.8.4-openjdk-11-slim

WORKDIR /app

# Копируем необходимые файлы Maven Wrapper
COPY mvnw ./
COPY .mvn ./.mvn
COPY pom.xml ./
COPY wait-for-it.sh .

# Делаем файлы исполняемыми
RUN chmod +x mvnw && chmod +x wait-for-it.sh

# Проверяем содержимое рабочей директории и структуры Maven Wrapper
RUN ls -la . && ls -la .mvn && ls -la .mvn/wrapper

# Устанавливаем зависимости
RUN unset MAVEN_CONFIG && ./mvnw dependency:go-offline

# Копируем исходный код
COPY src ./src

# Устанавливаем переменные окружения
ENV POSTGRES_HOST=postgres \
    POSTGRES_PORT=5432 \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=1 \
    POSTGRES_DB=payments_db

# Открываем порт
EXPOSE 8084

# Команда для запуска приложения
CMD ["./wait-for-it.sh", "database:5432", "--", "./mvnw", "spring-boot:run"]
