**ДЗ**

Задать структуру:

```
CREATE (alex:User {name: "Alex"}),
       (maria:User {name: "Maria"}),
       (john:User {name: "John"})

CREATE (inception:Movie {title: "Inception"}),
       (matrix:Movie {title: "The Matrix"})

MATCH (a:User {name: "Alex"}), (m:User {name: "Maria"})
CREATE (a)-[:FRIENDS]->(m)

MATCH (a:User {name: "Alex"}), (i:Movie {title: "Inception"})
CREATE (a)-[:WATCHED {rating: 5}]->(i)
```

Выполнить запросы:

- Найти всех друзей Алекса

- Найти фильмы, которые смотрели друзья Алекса, но не смотрел сам Алекс

Сравнить:

- Написать аналогичный запрос на SQL

- Сравнить сложность запросов

## Ответ

`docker-compose.yml`:

```yaml
version: "3.8"

services:
  neo4j:
    image: neo4j:5-enterprise
    container_name: neo4j
    ports:
      - "7474:7474"
      - "7687:7687"
    environment:
      - NEO4J_AUTH=neo4j/password123
      - NEO4J_ACCEPT_LICENSE_AGREEMENT=yes
      - NEO4J_PLUGINS=["apoc", "graph-data-science"]
    volumes:
      - ./neo4j/data:/data
      - ./neo4j/logs:/logs
      - ./neo4j/import:/var/lib/neo4j/import
```

Запуск:

```bash
docker compose up -d
docker exec -it neo4j cypher-shell -u neo4j -p password123
```

Создание структуры. Добавил связь `Maria -> The Matrix`, чтобы второй запрос вернул фильм, который смотрел друг Alex, но не смотрел сам Alex.

```cypher
MATCH (n) DETACH DELETE n;

CREATE (alex:User {name: "Alex"}),
       (maria:User {name: "Maria"}),
       (john:User {name: "John"});

CREATE (inception:Movie {title: "Inception"}),
       (matrix:Movie {title: "The Matrix"});

MATCH (a:User {name: "Alex"}), (m:User {name: "Maria"})
CREATE (a)-[:FRIENDS]->(m);

MATCH (a:User {name: "Alex"}), (i:Movie {title: "Inception"})
CREATE (a)-[:WATCHED {rating: 5}]->(i);

MATCH (maria:User {name: "Maria"}), (matrix:Movie {title: "The Matrix"})
CREATE (maria)-[:WATCHED {rating: 4}]->(matrix);
```

Найти всех друзей Алекса:

```cypher
MATCH (:User {name: "Alex"})-[:FRIENDS]->(friend:User)
RETURN friend.name AS friend;
```
```text
+---------+
| friend  |
+---------+
| "Maria" |
+---------+

```
Найти фильмы, которые смотрели друзья Алекса, но не смотрел сам Алекс:

```cypher
MATCH (alex:User {name: "Alex"})-[:FRIENDS]->(:User)-[:WATCHED]->(movie:Movie)
WHERE NOT (alex)-[:WATCHED]->(movie)
RETURN DISTINCT movie.title AS movie;
```
```text
+--------------+
| movie        |
+--------------+
| "The Matrix" |
+--------------+

```
Аналогичная структура в SQL:

```sql
CREATE TABLE users (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE movies (
  id serial PRIMARY KEY,
  title text NOT NULL UNIQUE
);

CREATE TABLE friendships (
  user_id int NOT NULL REFERENCES users(id),
  friend_id int NOT NULL REFERENCES users(id),
  PRIMARY KEY (user_id, friend_id)
);

CREATE TABLE watched (
  user_id int NOT NULL REFERENCES users(id),
  movie_id int NOT NULL REFERENCES movies(id),
  rating int,
  PRIMARY KEY (user_id, movie_id)
);
```

SQL-запрос друзей Алекса:

```sql
SELECT friend.name
FROM users alex
JOIN friendships f ON f.user_id = alex.id
JOIN users friend ON friend.id = f.friend_id
WHERE alex.name = 'Alex';
```

SQL-запрос фильмов друзей, которые не смотрел Алекс:

```sql
SELECT DISTINCT m.title
FROM users alex
JOIN friendships f ON f.user_id = alex.id
JOIN watched fw ON fw.user_id = f.friend_id
JOIN movies m ON m.id = fw.movie_id
WHERE alex.name = 'Alex'
  AND NOT EXISTS (
    SELECT 1
    FROM watched aw
    WHERE aw.user_id = alex.id
      AND aw.movie_id = m.id
  );
```

Сравнение сложности:

В Neo4j запрос короче и читается как путь по графу: `Alex -> friend -> watched movie`.
В SQL нужно явно описывать промежуточные таблицы связей и несколько `JOIN`.
Для графовых сценариев с друзьями, рекомендациями и путями Neo4j обычно проще.
Для табличных отчетов, транзакций и строгой реляционной модели удобнее SQL/PostgreSQL.
