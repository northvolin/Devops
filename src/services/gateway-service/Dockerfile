# Используем базовый образ Maven с JDK 11
FROM maven:3.8.4-openjdk-11-slim

# Устанавливаем рабочую директорию
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
ENV SESSION_SERVICE_HOST=session-service \
    SESSION_SERVICE_PORT=8081 \
    HOTEL_SERVICE_HOST=hotel-service \
    HOTEL_SERVICE_PORT=8082 \
    BOOKING_SERVICE_HOST=booking-service \
    BOOKING_SERVICE_PORT=8083 \
    PAYMENT_SERVICE_HOST=payment-service \
    PAYMENT_SERVICE_PORT=8084 \
    LOYALTY_SERVICE_HOST=loyalty-service \
    LOYALTY_SERVICE_PORT=8085 \
    REPORT_SERVICE_HOST=report-service \
    REPORT_SERVICE_PORT=8086

# Открываем порт
EXPOSE 8087

# Команда для запуска приложения
CMD ["./wait-for-it.sh", "database:5432", "--", "./mvnw", "spring-boot:run"]
