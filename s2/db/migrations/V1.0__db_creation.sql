CREATE SCHEMA if not exists marketplace;

-- 1. Таблица профессий (без изменений)
CREATE TABLE marketplace.profession (
                                        profession_id SERIAL PRIMARY KEY,
                                        name VARCHAR(255) NOT NULL UNIQUE,
                                        salary INT NOT NULL CHECK (salary > 0)
);

-- 2. Таблица карьерного роста (без изменений)
CREATE TABLE marketplace.career_path (
                                         path_id SERIAL PRIMARY KEY,
                                         current_profession_id INT NOT NULL REFERENCES marketplace.profession(profession_id),
                                         next_profession_id INT NOT NULL REFERENCES marketplace.profession(profession_id)
);

-- 3. Таблица работников (без изменений)
CREATE TABLE marketplace.workers (
                                     worker_id SERIAL PRIMARY KEY,
                                     login VARCHAR(255) NOT NULL UNIQUE,
                                     password_hash VARCHAR(255) NOT NULL,
                                     salt VARCHAR(50) NOT NULL
);

-- 4. Таблица покупателей (Расширена для заполнения)
CREATE TABLE marketplace.buyers (
                                    buyer_id SERIAL PRIMARY KEY,
                                    login VARCHAR(255) NOT NULL UNIQUE,                 -- высокая селективность (100% уникальных)
                                    password_hash VARCHAR(255) NOT NULL,
                                    salt VARCHAR(50) NOT NULL,

                                    email VARCHAR(255)                                  -- высокая селективность (≈90–100% уникальных), 5–20% NULL при заливке
);

-- 5. Таблица ПВЗ (без изменений)
CREATE TABLE marketplace.pvz (
                                 pvz_id SERIAL PRIMARY KEY,
                                 address VARCHAR(255) NOT NULL UNIQUE
);

-- 6. Таблица магазинов (без изменений)
CREATE TABLE marketplace.shops (
                                   shop_id SERIAL PRIMARY KEY,
                                   owner_id INT REFERENCES marketplace.workers(worker_id),
                                   name VARCHAR(255) NOT NULL UNIQUE
);

-- 7. Таблица категорий товаров (без изменений)
CREATE TABLE marketplace.category_of_item (
                                              category_id SERIAL PRIMARY KEY,
                                              name VARCHAR(255) NOT NULL UNIQUE,
                                              description TEXT
);

-- 8. Таблица товаров (Расширена для заполнения)
CREATE TABLE marketplace.items (
                                   item_id SERIAL PRIMARY KEY,
                                   shop_id INT NOT NULL REFERENCES marketplace.shops(shop_id),
                                   name VARCHAR(255) NOT NULL,
                                   description TEXT,                                   -- полнотекстовые данные
                                   category_id INT NOT NULL REFERENCES marketplace.category_of_item(category_id),
                                   price DECIMAL(10,2) NOT NULL CHECK (price >= 0),

                                   attributes JSONB NOT NULL DEFAULT '{}'::jsonb        -- JSONB
);


-- Индекс под полнотекстовый поиск по name+description (expression GIN index на to_tsvector).
CREATE INDEX items_fts_gin
    ON marketplace.items
        USING GIN ((to_tsvector('russian', coalesce(name,'') || ' ' || coalesce(description,''))));

-- 9. Таблица назначений работников (без изменений)
CREATE TABLE marketplace.worker_assignments (
                                                worker_id INT REFERENCES marketplace.workers(worker_id),
                                                place_type VARCHAR(20) CHECK (place_type = 'shop' OR place_type = 'pvz'),
                                                place_id INT,
                                                work_id INT REFERENCES marketplace.profession(profession_id)
);

-- 10. Таблица покупок (Расширена для заполнения)
CREATE TABLE marketplace.purchases (
                                       purchase_id SERIAL PRIMARY KEY,
                                       item_id INT NOT NULL REFERENCES marketplace.items(item_id),
                                       buyer_id INT NOT NULL REFERENCES marketplace.buyers(buyer_id),
                                       purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,   -- диапазонные значения (время), удобно для uniform
                                       status VARCHAR(50) DEFAULT 'completed'
                                           CHECK (status IN ('pending', 'completed', 'cancelled')) -- низкая селективность (3 значения)
);

-- 11. Таблица заказов (Расширена для заполнения)
CREATE TABLE marketplace.orders (
                                    order_id SERIAL PRIMARY KEY,
                                    purchase_id INT NOT NULL UNIQUE REFERENCES marketplace.purchases(purchase_id),
                                    pvz_id INT NOT NULL REFERENCES marketplace.pvz(pvz_id),
                                    status VARCHAR(50) NOT NULL DEFAULT 'created'
                                        CHECK (status IN ('created', 'delivered', 'cancelled')), -- низкая селективность (3 значения)
                                    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- диапазонные значения (время)

                                    delivery_slot TSTZRANGE,                              -- range-тип
                                    delivered_at TIMESTAMP                                -- NULL для created/cancelled; NOT NULL для delivered (5–20%+ NULL)
);

CREATE INDEX IF NOT EXISTS orders_delivered_at_partial -- для анализа partial index
    ON marketplace.orders(delivered_at)
    WHERE delivered_at IS NOT NULL;


-- 12. Таблица отзывов (без изменений)
CREATE TABLE marketplace.reviews (
                                     review_id SERIAL PRIMARY KEY,
                                     purchase_id INT NOT NULL UNIQUE REFERENCES marketplace.purchases(purchase_id),
                                     rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
                                     description TEXT
);