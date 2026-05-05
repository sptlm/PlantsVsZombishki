# MongoDB — Запуск-гайд

## Требования

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

## docker-compose.yml

```yaml
services:
  mongodb:
    image: mongo:8
    environment:
      - MONGO_INITDB_ROOT_USERNAME=root
      - MONGO_INITDB_ROOT_PASSWORD=root
    ports:
      - "27017:27017"
    volumes:
      - mongodb-data:/data/db
    networks:
      - mongodb-network

volumes:
  mongodb-data:

networks:
  mongodb-network:
    driver: bridge
```

| Параметр | Значение |
|---|---|
| Образ | `mongo:8` |
| Пользователь | `root` |
| Пароль | `root` |
| Порт | `27017` |
| Volume | `mongodb-data` → `/data/db` |
| Сеть | `mongodb-network` (bridge) |

## Запуск

1. Клонировать репозиторий и перейти в папку проекта

2. Запустить контейнер:

```bash
docker compose up -d
```

3. Узнать ID контейнера:

```bash
docker ps
```

4. Подключиться к MongoDB через `mongosh`:

```bash
docker exec -it <container_id> mongosh -u root -p root
```

5. Создать / переключиться на базу данных:

```js
use myDatabase
```

## Другой вариант

1. Скачать MongoDB Compass (https://www.mongodb.com/products/tools/compass)

2. Открыть его и ввести строку подключения:
```
mongodb://root:root@localhost:27017/
```
3. Создать базу данны

## Остановка

```bash
docker compose down
```

Для удаления данных вместе с volume:

```bash
docker compose down -v
```
