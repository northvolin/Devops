# Указываем базовый образ
FROM rabbitmq:3-management-alpine

# Позволяет использовать переменные окружения внутри контейнера
ENV RABBIT_MQ_USER=guest \
    RABBIT_MQ_PASSWORD=guest \
	RABBIT_MQ_QUEUE_NAME=messagequeue

# Открываем порт на котором будет доступен RabbitMQ (по умолчанию 5672)
EXPOSE 5672

# Открываем порт для управления RabbitMQ (по умолчанию 15672)
EXPOSE 15672

# Запускаем RabbitMQ при старте контейнера
CMD ["rabbitmq-server"]
