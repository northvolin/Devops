## Part 1. Запуск нескольких docker-контейнер
ов с использованием docker compose


Настройка окружения запускается скриптом 
sudo chmod +x environment.sh



[envirinment.sh](..%2Fenvirinment.sh)



1) Написать Dockerfile для каждого отдельного микросервиса.В отчете отобразить размер собранных образов любого сервиса различными способами.

#### Использование команды docker inspect

docker inspect 

for image in $(docker images -q); do
echo "Image ID: $image"
docker inspect --format='{{.RepoTags}}: {{.Size}}' $image
done

![3docker_images_inspect.png](screenshots%2F3docker_images_inspect.png)


#### Использование команды docker system df

docker system df -v

![2docker_images_df-v.png](screenshots%2F2docker_images_df-v.png)

#### Комбинированный метод

echo "Images:"
docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}'

echo -e "\nContainers:"
docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Size}}'

![4docker_images_combi.png](screenshots%2F4docker_images_combi.png)


#### Использование docker images

![1docker_images.png](screenshots%2F1docker_images.png)


digglega@digglega-HP-ProBook-650-G1:~/Documents/s21_projects/DevOps_7-1/src$ cat docker-compose.yml
version: '3.8'

services:
database:
build: ./services/database
environment:
POSTGRES_USER: postgres
POSTGRES_PASSWORD: 1
ports:
- "5433:5432"
networks:
- local-network

rabbitmq:
image: rabbitmq:3-management-alpine
ports:
- "5672:5672"
- "15672:15672"
networks:
- local-network

session-service:
build: ./services/session-service
environment:
POSTGRES_HOST: database
POSTGRES_PORT: 5432
POSTGRES_USER: postgres
POSTGRES_PASSWORD: 1
POSTGRES_DB: users_db
depends_on:
- database
- rabbitmq
ports:
- "8081:8081"
networks:
- local-network

hotel-service:
build: ./services/hotel-service
environment:
POSTGRES_HOST: database
POSTGRES_PORT: 5432
POSTGRES_USER: postgres
POSTGRES_PASSWORD: 1
POSTGRES_DB: hotels_db
depends_on:
- database
- rabbitmq
ports:
- "8082:8082"
networks:
- local-network

payment-service:
build: ./services/payment-service
environment:
POSTGRES_HOST: database
POSTGRES_PORT: 5432
POSTGRES_USER: postgres
POSTGRES_PASSWORD: 1
POSTGRES_DB: payments_db
depends_on:
- database
- rabbitmq
ports:
- "8084:8084"
networks:
- local-network

loyalty-service:
build: ./services/loyalty-service
environment:
POSTGRES_HOST: database
POSTGRES_PORT: 5432
POSTGRES_USER: postgres
POSTGRES_PASSWORD: 1
POSTGRES_DB: balances_db
depends_on:
- database
- rabbitmq
ports:
- "8085:8085"
networks:
- local-network

report-service:
build: ./services/report-service
environment:
POSTGRES_HOST: database
POSTGRES_PORT: 5432
POSTGRES_USER: postgres
POSTGRES_PASSWORD: 1
POSTGRES_DB: statistics_db
RABBIT_MQ_HOST: rabbitmq
RABBIT_MQ_PORT: 5672
RABBIT_MQ_USER: guest
RABBIT_MQ_PASSWORD: guest
RABBIT_MQ_QUEUE_NAME: messagequeue
RABBIT_MQ_EXCHANGE: messagequeue-exchange
depends_on:
- database
- rabbitmq
ports:
- "8086:8086"
networks:
- local-network

booking-service:
build: ./services/booking-service
environment:
POSTGRES_HOST: database
POSTGRES_PORT: 5432
POSTGRES_USER: postgres
POSTGRES_PASSWORD: 1
POSTGRES_DB: reservations_db
RABBIT_MQ_HOST: rabbitmq
RABBIT_MQ_PORT: 5672
RABBIT_MQ_USER: guest
RABBIT_MQ_PASSWORD: guest
RABBIT_MQ_QUEUE_NAME: messagequeue
RABBIT_MQ_EXCHANGE: messagequeue-exchange
HOTEL_SERVICE_HOST: hotel-service
HOTEL_SERVICE_PORT: 8082
PAYMENT_SERVICE_HOST: payment-service
PAYMENT_SERVICE_PORT: 8084
LOYALTY_SERVICE_HOST: loyalty-service
LOYALTY_SERVICE_PORT: 8085
depends_on:
- database
- rabbitmq
- hotel-service
- payment-service
- loyalty-service
ports:
- "8083:8083"
networks:
- local-network

gateway-service:
build: ./services/gateway-service
environment:
SESSION_SERVICE_HOST: session-service
SESSION_SERVICE_PORT: 8081
HOTEL_SERVICE_HOST: hotel-service
HOTEL_SERVICE_PORT: 8082
BOOKING_SERVICE_HOST: booking-service
BOOKING_SERVICE_PORT: 8083
PAYMENT_SERVICE_HOST: payment-service
PAYMENT_SERVICE_PORT: 8084
LOYALTY_SERVICE_HOST: loyalty-service
LOYALTY_SERVICE_PORT: 8085
REPORT_SERVICE_HOST: report-service
REPORT_SERVICE_PORT: 8086
depends_on:
- session-service
- hotel-service
- booking-service
- payment-service
- loyalty-service
- report-service
ports:
- "8087:8087"
networks:
- local-network

networks:
local-network:
driver: bridge



3) Собрать и развернуть веб-сервис с помощью написанного docker compose файла на локальной машине.

сборка и настройка и запуск тестов осуществляется скриптом:

chmod +x start-services.sh




[start_services.sh](start_services.sh)


![build_services.png](screenshots%2Fbuild_services.png)


![buildede_on_local.png](screenshots%2Fbuildede_on_local.png)


4) Прогнать заготовленные тесты через postman и удостовериться, что все они проходят успешно.


![POSTman.png](screenshots%2FPOSTman.png)


![POstMAN.png](screenshots%2FPOstMAN.png)


![POSTMANNN.png](screenshots%2FPOSTMANNN.png)

## Part 2. Создание виртуальных машин


1) Установить и инициализировать Vagrant в корне проекта. Написать Vagrantfile для одной виртуальной машины. Перенести в виртуальную машину исходный код веб-сервиса в рабочую директорию виртуальной машины.

Для инициализации Vagrant применяем команду vagrant init в рабочей директории.

Прописываем все необходимые параметры запуска в Vagrantfile, а также указываем количество машин и указываем, что необходимо установить, а также синхронизируем папки.

![vagrantfile_part2.png](screenshots%2Fvagrantfile_part2.png)


#### Поднимаем машину командой vagrant up:

![vagrant_up_part2.png](screenshots%2Fvagrant_up_part2.png)


![vagrant_up1_part2.png](screenshots%2Fvagrant_up1_part2.png)


#### Заходим в машину и удостоверяемся, что все стало отлично

![vagrant_files_ssh_part2.png](screenshots%2Fvagrant_files_ssh_part2.png)

2) Зайти через консоль внутрь виртуальной машины и удостовериться, что исходный код встал куда нужно. Остановить и уничтожить виртуальную машину.

![vagrant_halt&destroy.png](screenshots%2Fvagrant_halt%26destroy.png)


## Part 3

) Модифицировать Vagrantfile для создания трех машин: manager01, worker01, worker02. Написать shell-скрипты для установки docker внутрь машин, инициализации и подключения к docker swarm.

![vag_1_p3.png](screenshots%2Fvag_1_p3.png)

![v2_p3.png](screenshots%2Fv2_p3.png)

2) Загрузить собранные образы на docker hub и модифицировать docker-compose файл для подгрузки расположенных на docker hub образов.

![Docker_push_p3.png](screenshots%2FDocker_push_p3.png)

![docker_c1_p3.png](screenshots%2Fdocker_c1_p3.png)

![docker_c2_p3.png](screenshots%2Fdocker_c2_p3.png)

![docker_c3_p3.png](screenshots%2Fdocker_c3_p3.png)

![docker_c4_p3.png](screenshots%2Fdocker_c4_p3.png)

3) Поднять виртуальные машины и перенести на менеджер docker-compose файл. Запустить стек сервисов, используя написанный docker-compose файл.

выполняем команду vagrant up

![vag_up1_p3.png](screenshots%2Fvag_up1_p3.png)

![vag_up2_p3.png](screenshots%2Fvag_up2_p3.png)

![vag_up3_p3.png](screenshots%2Fvag_up3_p3.png)

Подключаемся к управляющему узлу и запускаем стек сервисов:

![vagrant_manager1_p3.png](screenshots%2Fvagrant_manager1_p3.png)

![vagrant_manager2_p3.png](screenshots%2Fvagrant_manager2_p3.png)

4) Настроить прокси на базе nginx для доступа к gateway service и session service по оверлейной сети. 
Сами gateway service и session service сделать недоступными напрямую.

Так как мы реализуем обратный прокси рекомендуется запуск nginx как отдельного сервиса, 
таким образом мы отделим логику проксирования и маршрутизации от основного приложения.

Создаем в папке services еще один с названием nginx 

![nginx1_p3.png](screenshots%2Fnginx1_p3.png)

Добавляем Dockerfile и файл конфигурации nginx

![nginx2_p3.png](screenshots%2Fnginx2_p3.png)

![nginx_conf3_p3.png](screenshots%2Fnginx_conf3_p3.png)

обновляем docker-compose

![nginx4_p3.png](screenshots%2Fnginx4_p3.png)

Собираем образ и пушим:

docker build -t digglega/nginx:latest .
docker push digglega/nginx:latest

Сносим предыдущие машины и снова подымаем вагрант:
vagrant up 
и пока поднимаются серваки можно пойти запилить чаю)

vagrant ssh manager01

docker stack deploy -c docker-compose.yml my_stack

и проверяем запуск:

![docker_stack_my_stack_p3.png](screenshots%2Fdocker_stack_my_stack_p3.png)




Проверка доступности сервисов через Nginx
   Через IP-адрес менеджера, отправляйте запросы к gateway и session сервисам:

Gateway: http://<192.168.56.26>/gateway/
Session: http://<192.168.56.26>/session/


