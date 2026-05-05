# Домашнее задание

1. Поднять Elastic
2. Создать индекс
3. Заполнить данными
4. Написать 4 запроса (поиск по названию, фильтры, `match`, `range`, `term`, `bool`)

## Ответ

`docker-compose.yml`:

```yaml
services:
  elasticsearch:
    image: elasticsearch:7.17.22
    container_name: elasticsearch
    ports:
      - "9200:9200"
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data

volumes:
  elasticsearch-data:
```

Запуск:

```powershell
docker compose up -d
curl.exe http://localhost:9200
```

Создание индекса `products`:

```powershell
$mapping = @'
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      },
      "category": {
        "type": "keyword"
      },
      "brand": {
        "type": "keyword"
      },
      "price": {
        "type": "double"
      },
      "in_stock": {
        "type": "boolean"
      },
      "created_at": {
        "type": "date"
      }
    }
  }
}
'@

$mapping | curl.exe -X PUT "http://localhost:9200/products" `
  -H "Content-Type: application/json" `
  --data-binary "@-"
```

Заполнение данными через `_bulk`:

```powershell
curl.exe -X POST "http://localhost:9200/products/_bulk?refresh=true" `
  -H "Content-Type: application/x-ndjson" `
  --data-binary "@products.ndjson"
```

`products.ndjson`:

```json
{"index":{"_id":1}}
{"title":"Apple iPhone 15","category":"smartphone","brand":"Apple","price":899.99,"in_stock":true,"created_at":"2026-05-01"}
{"index":{"_id":2}}
{"title":"Samsung Galaxy S24","category":"smartphone","brand":"Samsung","price":799.99,"in_stock":true,"created_at":"2026-04-20"}
{"index":{"_id":3}}
{"title":"Apple MacBook Air M3","category":"laptop","brand":"Apple","price":1299.00,"in_stock":false,"created_at":"2026-03-11"}
{"index":{"_id":4}}
{"title":"Lenovo ThinkPad X1 Carbon","category":"laptop","brand":"Lenovo","price":1499.50,"in_stock":true,"created_at":"2026-02-15"}
{"index":{"_id":5}}
{"title":"Sony WH-1000XM5 Headphones","category":"audio","brand":"Sony","price":349.99,"in_stock":true,"created_at":"2026-01-30"}
```

Если не хочется создавать файл, те же данные можно вставить одной командой в PowerShell:

```powershell
$bulk = @'
{"index":{"_id":1}}
{"title":"Apple iPhone 15","category":"smartphone","brand":"Apple","price":899.99,"in_stock":true,"created_at":"2026-05-01"}
{"index":{"_id":2}}
{"title":"Samsung Galaxy S24","category":"smartphone","brand":"Samsung","price":799.99,"in_stock":true,"created_at":"2026-04-20"}
{"index":{"_id":3}}
{"title":"Apple MacBook Air M3","category":"laptop","brand":"Apple","price":1299.00,"in_stock":false,"created_at":"2026-03-11"}
{"index":{"_id":4}}
{"title":"Lenovo ThinkPad X1 Carbon","category":"laptop","brand":"Lenovo","price":1499.50,"in_stock":true,"created_at":"2026-02-15"}
{"index":{"_id":5}}
{"title":"Sony WH-1000XM5 Headphones","category":"audio","brand":"Sony","price":349.99,"in_stock":true,"created_at":"2026-01-30"}
'@

$bulk | curl.exe -X POST "http://localhost:9200/products/_bulk?refresh=true" `
  -H "Content-Type: application/x-ndjson" `
  --data-binary "@-"
```

1. Поиск по названию:

```powershell
$query = @'
{
  "query": {
    "match": {
      "title": "iphone"
    }
  }
}
'@

$query | curl.exe -X GET "http://localhost:9200/products/_search?pretty" `
  -H "Content-Type: application/json" `
  --data-binary "@-"
```

Вывод:
```text
{
  "took" : 92,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 1.4877305,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.4877305,
        "_source" : {
          "title" : "Apple iPhone 15",
          "category" : "smartphone",
          "brand" : "Apple",
          "price" : 899.99,
          "in_stock" : true,
          "created_at" : "2026-05-01"
        }
      }
    ]
  }
}

```

2. `match`:

```powershell
$query = @'
{
  "query": {
    "match": {
      "title": "Apple laptop"
    }
  }
}
'@

$query | curl.exe -X GET "http://localhost:9200/products/_search?pretty" `
  -H "Content-Type: application/json" `
  --data-binary "@-"
```
Вывод:
```text
{
  "took" : 19,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 0.9395274,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 0.9395274,
        "_source" : {
          "title" : "Apple iPhone 15",
          "category" : "smartphone",
          "brand" : "Apple",
          "price" : 899.99,
          "in_stock" : true,
          "created_at" : "2026-05-01"
        }
      },
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "3",
        "_score" : 0.83740485,
        "_source" : {
          "title" : "Apple MacBook Air M3",
          "category" : "laptop",
          "brand" : "Apple",
          "price" : 1299.0,
          "in_stock" : false,
          "created_at" : "2026-03-11"
        }
      }
    ]
  }
}

```
3. `range`:

```powershell
$query = @'
{
  "query": {
    "range": {
      "price": {
        "gte": 500,
        "lte": 1000
      }
    }
  }
}
'@

$query | curl.exe -X GET "http://localhost:9200/products/_search?pretty" `
  -H "Content-Type: application/json" `
  --data-binary "@-"
```
Вывод: 
```text
{
  "took" : 15,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "title" : "Apple iPhone 15",
          "category" : "smartphone",
          "brand" : "Apple",
          "price" : 899.99,
          "in_stock" : true,
          "created_at" : "2026-05-01"
        }
      },
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 1.0,
        "_source" : {
          "title" : "Samsung Galaxy S24",
          "category" : "smartphone",
          "brand" : "Samsung",
          "price" : 799.99,
          "in_stock" : true,
          "created_at" : "2026-04-20"
        }
      }
    ]
  }
}

```

4. `term`:

```powershell
$query = @'
{
  "query": {
    "term": {
      "category": "smartphone"
    }
  }
}
'@

$query | curl.exe -X GET "http://localhost:9200/products/_search?pretty" `
  -H "Content-Type: application/json" `
  --data-binary "@-"
```
Вывод:
```text
{
  "took" : 3,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 0.87546873,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 0.87546873,
        "_source" : {
          "title" : "Apple iPhone 15",
          "category" : "smartphone",
          "brand" : "Apple",
          "price" : 899.99,
          "in_stock" : true,
          "created_at" : "2026-05-01"
        }
      },
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 0.87546873,
        "_source" : {
          "title" : "Samsung Galaxy S24",
          "category" : "smartphone",
          "brand" : "Samsung",
          "price" : 799.99,
          "in_stock" : true,
          "created_at" : "2026-04-20"
        }
      }
    ]
  }
}

```

5. `bool` с фильтрами:

```powershell
$query = @'
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "title": "Apple"
          }
        }
      ],
      "filter": [
        {
          "term": {
            "in_stock": true
          }
        },
        {
          "range": {
            "price": {
              "lte": 1000
            }
          }
        }
      ]
    }
  }
}
'@

$query | curl.exe -X GET "http://localhost:9200/products/_search?pretty" `
  -H "Content-Type: application/json" `
  --data-binary "@-"
```
Вывод:
```text
{
  "took" : 6,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 0.9395274,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 0.9395274,
        "_source" : {
          "title" : "Apple iPhone 15",
          "category" : "smartphone",
          "brand" : "Apple",
          "price" : 899.99,
          "in_stock" : true,
          "created_at" : "2026-05-01"
        }
      }
    ]
  }
}

```