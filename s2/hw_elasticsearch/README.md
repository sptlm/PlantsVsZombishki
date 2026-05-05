# Elasticsearch

## Запуск

```bash
docker run -p 9200:9200 -e "discovery.type=single-node" elasticsearch:7.17.22
```

В папке прикрепил коллекцию запросов в Postman, её можно использовать для выполнения домашки