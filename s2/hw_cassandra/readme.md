
## 1. Быстрый старт (Docker)

Запуск контейнера (в фоновом режиме):

`docker run --name cassandra-node -p 9042:9042 -d cassandra:latest  `

Вход в консоль запросов (CQLSH):

`docker exec -it cassandra-node cqlsh  `
  
## 1.1 Docker compose


services:  
  node1:  
    image: cassandra:latest  
    container_name: cassandra-node1  
    ports:  
      - "9042:9042"  
    volumes:  
      - cassandra_node1_data:/var/lib/cassandra  
    environment:  
      - CASSANDRA_CLUSTER_NAME=TestCluster  
      - CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch  
      - MAX_HEAP_SIZE=256M  
      - HEAP_NEWSIZE=64M  
    healthcheck:  
      test: ["CMD-SHELL", "nodetool status | grep -E '^UN'"]  
      interval: 15s  
      timeout: 10s  
      retries: 10  
  
  node2:  
    image: cassandra:latest  
    container_name: cassandra-node2  
    volumes:  
      - cassandra_node2_data:/var/lib/cassandra  
    environment:  
      - CASSANDRA_CLUSTER_NAME=TestCluster  
      - CASSANDRA_SEEDS=node1  
      - CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch  
      - MAX_HEAP_SIZE=256M  
      - HEAP_NEWSIZE=64M  
    depends_on:  
      node1:  
        condition: service_healthy  
  
volumes:  
  cassandra_node1_data:  
  cassandra_node2_data:



## 2. Шпаргалка по командам (CQL)

Ниже приведены основные команды, которые пригодятся в работе с cqlsh:

*Просмотр всех Keyspace 

`DESCRIBE KEYSPACES;  `
  
*Создание Keyspace (аналог БД) для локальной разработки*

`CREATE KEYSPACE my_app WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};  `
  
*Переключение на Keyspace  *

`USE my_app;  `
  
*Создание таблицы с Partition Key (user_id) и Clustering Key (created_at)  *

```cql
CREATE TABLE users_logs (  
    user_id uuid,  
    created_at timestamp,  
    action text,  
    PRIMARY KEY (user_id, created_at)  
) WITH CLUSTERING ORDER BY (created_at DESC);  
```
*Просмотр структуры таблицы  *

`DESCRIBE TABLE users_logs;  `
  
*Проверка и изменение уровня консистентности  

`CONSISTENCY;  `
`CONSISTENCY QUORUM;  `
  
*Вставка данных (работает как Upsert: перезапишет, если ключ уже есть)  

`INSERT INTO users_logs (user_id, created_at, action)  
`VALUES (uuid(), toTimestamp(now()), 'LOGIN');  `
  
*Вставка данных с автоудалением через 60 секунд (TTL)  *

`INSERT INTO users_logs (user_id, created_at, action)  `
`VALUES (123e4567-e89b-12d3-a456-426614174000, '2026-03-29 10:00:00', 'CLICK')  `
`USING TTL 60;  `
  
*Выборка данных (Обязательно указать Partition Key!)  

`SELECT * FROM users_logs WHERE user_id = 123e4567-e89b-12d3-a456-426614174000;`  

*Выборка с фильтрацией по Clustering Key (диапазон)  *

`SELECT * FROM users_logs  `
`WHERE user_id = 123e4567-e89b-12d3-a456-426614174000  `
`  AND created_at >= '2026-01-01 00:00:00';  `
  
*Удаление конкретной записи (создаст метку Tombstone)  

`DELETE FROM users_logs  `
`WHERE user_id = 123e4567-e89b-12d3-a456-426614174000  `
`  AND created_at = '2026-03-29 10:00:00';  `
