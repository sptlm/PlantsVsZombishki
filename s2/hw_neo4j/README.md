**Запуск Neo4j**

Для запуска Neo4j необходимо выполнить следующие шаги:

Создать docker-compose.yml c следующим содержимым:

```yaml
version: '3.8'
services:
  neo4j:
    image: neo4j:5-enterprise
    container_name: neo4j
    ports:
      - "7474:7474"   # HTTP Browser
      - "7687:7687"   # Bolt protocol
    environment:
      - NEO4J_AUTH=neo4j/password123
      - NEO4J_ACCEPT_LICENSE_AGREEMENT=yes
      - NEO4J_PLUGINS='["apoc", "graph-data-science"]'
    volumes:
      - ./neo4j/data:/data
      - ./neo4j/logs:/logs
      - ./neo4j/import:/var/lib/neo4j/import
```

Просмотр:

Web GUI: 
>Открыть http://localhost:7474

CLI: 
>docker exec -it neo4j cypher-shell -u neo4j -p password123

HTTP API: 
>curl -X POST http://localhost:7474/db/neo4j/tx/commit \
-H "Content-Type: application/json" \
-u neo4j:password123 \
-d '{"statements":[{"statement":"RETURN 1 AS result"}]}'



