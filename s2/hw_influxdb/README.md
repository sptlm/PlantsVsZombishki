# InfluxDB — Запуск-гайд

## Предварительные требования: установлен Docker и Docker Compose

## Создание docker-compose.yml  
```yml
version: '3.9'

services:  
  influxdb:  
    image: influxdb:2.7  
    container_name: influxdb  
    ports:  
      - "8086:8086"  
    environment:  
      - DOCKER_INFLUXDB_INIT_MODE=setup  
      - DOCKER_INFLUXDB_INIT_USERNAME=admin  
      - DOCKER_INFLUXDB_INIT_PASSWORD=admin123456  
      - DOCKER_INFLUXDB_INIT_ORG=myorg  
      - DOCKER_INFLUXDB_INIT_BUCKET=mybucket  
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=my-token-123  
    volumes:  
      - influxdb-data:/var/lib/influxdb

volumes:  
  influxdb-data:
```

## Запуск контейнера  
docker compose up -d

## Открытие веб-интерфейса  
[http://localhost:8086](http://localhost:8086)

## Ввести данные, которые указали в docker-compose.yml