# network-task
Репозиторий с решением задания по кафедральному предмету Сети.

## Задание

Необходимо создать скрипт или семейство скриптов, который(-ое) с помощью Linux Traffic Control настроит оптимальную серверную сетевую инфраструктуру.
На инфраструктуру накладываются следующие требования (70% баллов):
- есть четыре блока IP-адресов, которые условно определяют географическую принадлежность клиента;
- клиент из географической зоны #1 должен получать 40% пропускной способности, остальные - по 20%;
- все ICMP-пакеты от любого клиента должны быть проигнорированы (отфильтрованы) (подсказка: идентификатор протокола см. в /etc/protocols);
- для клиента из географической зоны #2 UDP-трафик должен иметь приоритет над остальным трафиком;
- все SSH-запросы от клиента из географической зоны #4 должны быть проигнорированы.

Описанная сеть должна быть смоделирована с помощью docker-контейнеров с применением docker-compose (30% баллов).

### Требования
- В репозитории с заданием должен присутствовать файл README с описанием процесса сборки/запуска вашего проекта
- Наличие багов/вылетов etc недопустимо

# Описание работы
Решение состоит из файлов Dockerfile, docker-compose и run.sh.
Чтобы собрать необходимый для работы образ, необходимо, находясь в папке с Dockerfile, выполнить команду:
```
docker build -t networks:latest .
```
После сборки необходимо запустить docker compose. Для этого нужно выполнить следующую команду:
```
docker compose up -d
```

Образ контейнера содержит необходимые для настройки и тестирования утилиты, такие как:
- iproute2, netbase - для настройки сетевого взаимодействия
- inetutils-ping, ssh, iperf3 - для тестирования соблюдения наложенных требований

В данном контейнере запущен процесс iperf3 в режиме серверва `iperf3 -s -p 8080` для того, чтобы контейнер продолжал работать после запуска, и была возможность проверки ограничения на скорость между зонами.

Все контейнеры работают в одной сети 192.160.0.0/16. Зоны определяются следующим образом:

> 192.160.n.0/24 - где n = (1 ... 4) - номер зоны

То есть адрес для ноды из первой зоны будет иметь вид 192.160.1.1, когда для четвертой - 192.160.4.1.