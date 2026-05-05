# 🚀 ClickHouse + PostgreSQL — Запуск

## 📋 Предварительные требования

Перед началом убедись, что у тебя установлены:

- Docker
- Docker Compose

---

## ⚡ Быстрый запуск

```bash
# 1. Перейти в папку с docker-compose.yml
cd /путь/к/папке

# 2. Запустить контейнеры
docker compose up -d

# 3. Проверить статус
docker compose ps

# определенный контейнер
docker exec -it clickhouse-lab clickhouse-client --password password
docker exec -it postgres-lab psql -U postgres -d postgres


# Остановить контейнеры (данные сохранятся)
docker compose down

# Остановить и удалить все данные
ClickHouse	8123	curl http://localhost:8123
ClickHouse	9000	clickhouse-client --port 9000
PostgreSQL	5432	psql -h localhost -p 5432 -U postgres
```
