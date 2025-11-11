```
TRUNCATE TABLE marketplace.reviews RESTART IDENTITY CASCADE;
TRUNCATE TABLE marketplace.orders RESTART IDENTITY CASCADE;
TRUNCATE TABLE marketplace.purchases RESTART IDENTITY CASCADE;
TRUNCATE TABLE marketplace.worker_assignments RESTART IDENTITY CASCADE;
TRUNCATE TABLE marketplace.items RESTART IDENTITY CASCADE;
TRUNCATE TABLE marketplace.shops RESTART IDENTITY CASCADE;
TRUNCATE TABLE marketplace.pvz RESTART IDENTITY CASCADE;
TRUNCATE TABLE marketplace.buyers RESTART IDENTITY CASCADE;
TRUNCATE TABLE marketplace.workers RESTART IDENTITY CASCADE;
TRUNCATE TABLE marketplace.career_path RESTART IDENTITY CASCADE;
TRUNCATE TABLE marketplace.profession RESTART IDENTITY CASCADE;
TRUNCATE TABLE marketplace.category_of_item RESTART IDENTITY CASCADE;
```

Независимые данные
```
-- Профессии (20)
INSERT INTO marketplace.profession (name, salary) VALUES
('Младший разработчик', 60000), ('Разработчик среднего уровня', 120000), ('Старший разработчик', 210000), ('Ведущий разработчик', 250000),
('Младший тестировщик', 70000), ('Тестировщик среднего уровня', 120000), ('Ведущий тестировщик', 150000), ('Системный администратор', 110000),
('Бизнес-аналитик', 130000), ('Владелец продукта', 170000), ('Администратор баз данных', 155000), ('HR специалист', 80000),
('Рекрутер', 85000), ('UX дизайнер', 110000), ('Менеджер проекта', 175000), ('Специалист по социальным сетям', 70000),
('Копирайтер', 65000), ('Мобильный разработчик', 140000), ('Разработчик игр', 145000), ('Директор по информационным технологиям', 270000);

-- Категории товаров (15)
INSERT INTO marketplace.category_of_item (name, description) VALUES
('Электроника', 'Техника и гаджеты'), ('Книги', 'Различная литература'), ('Одежда', 'Вещи для гардероба'),
('Игрушки', 'Для детей всех возрастов'), ('Продукты питания', 'Продукты и деликатесы'), ('Косметика', 'Средства ухода и красоты'),
('Спортивные товары', 'Все для спортсменов'), ('Инструменты', 'Для ремонта и строительства'), ('Товары для дома', 'Уют и быт'),
('Товары для животных', 'Аксессуары и корма'), ('Мебель', 'Для дома и офиса'), ('Канцелярские товары', 'Для школы и работы'),
('Автоаксессуары', 'Товары для автомобилей'), ('Музыкальные инструменты', 'Инструменты и записи'), ('Товары для творчества', 'Материалы для рукоделия');

-- ПВЗ (50)
INSERT INTO marketplace.pvz (address) VALUES
('ул. Первомайская, 1'), ('ул. Советская, 2'), ('ул. Горького, 3'), ('пр. Ленина, 4'), ('ул. Мира, 5'),
('ул. Центральная, 6'), ('ул. Ладыгина, 7'), ('ул. Механизаторов, 8'), ('ул. Космонавтов, 9'), ('ул. Чехова, 10'),
('ул. Железнодорожная, 11'), ('ул. Кирова, 12'), ('ул. Рощинская, 13'), ('ул. Калинина, 14'), ('ул. Академика Павлова, 15'),
('ул. Школьная, 16'), ('ул. Молодежная, 17'), ('ул. Северная, 18'), ('ул. Южная, 19'), ('ул. Транспортная, 20'),
('ул. Короткая, 21'), ('ул. Гаражная, 22'), ('ул. Белорусская, 23'), ('ул. Карла Маркса, 24'), ('ул. Победы, 25'),
('ул. Новая, 26'), ('ул. Полевая, 27'), ('ул. Лесная, 28'), ('ул. Садовая, 29'), ('ул. Восточная, 30'),
('ул. Западная, 31'), ('ул. Верхняя, 32'), ('ул. Нижняя, 33'), ('ул. Летняя, 34'), ('ул. Весенняя, 35'),
('ул. Осенняя, 36'), ('ул. Зимняя, 37'), ('ул. Интернациональная, 38'), ('ул. Советская, 39'), ('ул. Партизанская, 40'),
('ул. Трудовая, 41'), ('ул. Солнечная, 42'), ('ул. Луговая, 43'), ('ул. Сиреневая, 44'), ('ул. Цветочная, 45'),
('ул. Вишневая, 46'), ('ул. Вокзальная, 47'), ('ул. Энергетиков, 48'), ('ул. Яблоневая, 49'), ('ул. Центральная, 50');

-- Работники (30)
INSERT INTO marketplace.workers (login, password_hash, salt) VALUES
('user001', 'hash001', 'salt001'), ('user002', 'hash002', 'salt002'), ('user003', 'hash003', 'salt003'),
('user004', 'hash004', 'salt004'), ('user005', 'hash005', 'salt005'), ('user006', 'hash006', 'salt006'),
('user007', 'hash007', 'salt007'), ('user008', 'hash008', 'salt008'), ('user009', 'hash009', 'salt009'),
('user010', 'hash010', 'salt010'), ('user011', 'hash011', 'salt011'), ('user012', 'hash012', 'salt012'),
('user013', 'hash013', 'salt013'), ('user014', 'hash014', 'salt014'), ('user015', 'hash015', 'salt015'),
('user016', 'hash016', 'salt016'), ('user017', 'hash017', 'salt017'), ('user018', 'hash018', 'salt018'),
('user019', 'hash019', 'salt019'), ('user020', 'hash020', 'salt020'), ('user021', 'hash021', 'salt021'),
('user022', 'hash022', 'salt022'), ('user023', 'hash023', 'salt023'), ('user024', 'hash024', 'salt024'),
('user025', 'hash025', 'salt025'), ('user026', 'hash026', 'salt026'), ('user027', 'hash027', 'salt027'),
('user028', 'hash028', 'salt028'), ('user029', 'hash029', 'salt029'), ('user030', 'hash030', 'salt030');

-- Покупатели (50)
INSERT INTO marketplace.buyers (login, password_hash, salt) VALUES
('buyer001', 'hash101', 'salt101'), ('buyer002', 'hash102', 'salt102'), ('buyer003', 'hash103', 'salt103'),
('buyer004', 'hash104', 'salt104'), ('buyer005', 'hash105', 'salt105'), ('buyer006', 'hash106', 'salt106'),
('buyer007', 'hash107', 'salt107'), ('buyer008', 'hash108', 'salt108'), ('buyer009', 'hash109', 'salt109'),
('buyer010', 'hash110', 'salt110'), ('buyer011', 'hash111', 'salt111'), ('buyer012', 'hash112', 'salt112'),
('buyer013', 'hash113', 'salt113'), ('buyer014', 'hash114', 'salt114'), ('buyer015', 'hash115', 'salt115'),
('buyer016', 'hash116', 'salt116'), ('buyer017', 'hash117', 'salt117'), ('buyer018', 'hash118', 'salt118'),
('buyer019', 'hash119', 'salt119'), ('buyer020', 'hash120', 'salt120'), ('buyer021', 'hash121', 'salt121'),
('buyer022', 'hash122', 'salt122'), ('buyer023', 'hash123', 'salt123'), ('buyer024', 'hash124', 'salt124'),
('buyer025', 'hash125', 'salt125'), ('buyer026', 'hash126', 'salt126'), ('buyer027', 'hash127', 'salt127'),
('buyer028', 'hash128', 'salt128'), ('buyer029', 'hash129', 'salt129'), ('buyer030', 'hash130', 'salt130'),
('buyer031', 'hash131', 'salt131'), ('buyer032', 'hash132', 'salt132'), ('buyer033', 'hash133', 'salt133'),
('buyer034', 'hash134', 'salt134'), ('buyer035', 'hash135', 'salt135'), ('buyer036', 'hash136', 'salt136'),
('buyer037', 'hash137', 'salt137'), ('buyer038', 'hash138', 'salt138'), ('buyer039', 'hash139', 'salt139'),
('buyer040', 'hash140', 'salt140'), ('buyer041', 'hash141', 'salt141'), ('buyer042', 'hash142', 'salt142'),
('buyer043', 'hash143', 'salt143'), ('buyer044', 'hash144', 'salt144'), ('buyer045', 'hash145', 'salt145'),
('buyer046', 'hash146', 'salt146'), ('buyer047', 'hash147', 'salt147'), ('buyer048', 'hash148', 'salt148'),
('buyer049', 'hash149', 'salt149'), ('buyer050', 'hash150', 'salt150');

-- Карьерные переходы (15)
INSERT INTO marketplace.career_path (current_profession_id, next_profession_id) VALUES
(1,2),(2,3),(3,4),(5,6),(6,7),(7,1),(8,9),(9,10),(10,11),(11,12),(12,13),(13,14),(14,15),(15,16),(16,17);
```


Зависимые данные
```
-- Магазины (30)
INSERT INTO marketplace.shops (owner_id, name) VALUES
(1, 'Магазин 1'), (2, 'Магазин 2'), (3, 'Магазин 3'), (4, 'Магазин 4'), (5, 'Магазин 5'),
(6, 'Магазин 6'), (7, 'Магазин 7'), (8, 'Магазин 8'), (9, 'Магазин 9'), (10, 'Магазин 10'),
(11, 'Магазин 11'), (12, 'Магазин 12'), (13, 'Магазин 13'), (14, 'Магазин 14'), (15, 'Магазин 15'),
(16, 'Магазин 16'), (17, 'Магазин 17'), (18, 'Магазин 18'), (19, 'Магазин 19'), (20, 'Магазин 20'),
(21, 'Магазин 21'), (22, 'Магазин 22'), (23, 'Магазин 23'), (24, 'Магазин 24'), (25, 'Магазин 25'),
(26, 'Магазин 26'), (27, 'Магазин 27'), (28, 'Магазин 28'), (29, 'Магазин 29'), (30, 'Магазин 30');

-- Товары (60)
INSERT INTO marketplace.items (shop_id, name, description, category_id, price) VALUES
(1, 'Ноутбук', 'Быстрый ноутбук', 1, 95000.00), (1, 'Смартфон', 'Флагман', 2, 53000.00),
(2, 'Книга Java', 'Учебник', 2, 1200.00), (2, 'Книга Python', 'Учебник', 2, 900.00),
(3, 'Футболка', 'Хлопок', 3, 1200.00), (3, 'Джинсы', 'Синие', 3, 2000.00),
(4, 'Плюшевый мишка', 'Игрушка', 4, 800.00), (4, 'Радиоуправляемая машинка', 'RC', 4, 4300.00),
(5, 'Чай', 'Зелёный', 5, 350.00), (5, 'Шоколад', 'Горький', 5, 180.00),
(6, 'Крем для лица', 'Увлажняющий', 6, 610.00), (6, 'Шампунь', 'Питательный', 6, 480.00),
(7, 'Гантели', '10 кг', 7, 2200.00), (7, 'Беговая дорожка', 'Складная', 7, 29000.00),
(8, 'Дрель', 'Аккумуляторная', 8, 3400.00), (8, 'Перфоратор', 'Режим удар', 8, 3700.00),
(9, 'Газонокосилка', 'Электрическая', 9, 5600.00), (9, 'Лопата', 'Стальная', 9, 950.00),
(10, 'Бумага', 'А4, 500 листов', 10, 450.00), (10, 'Ручка гелевая', 'Синяя', 10, 60.00),
(11, 'Щетка стеклоочистителя', 'Для авто', 11, 600.00), (11, 'Коврики', 'Резиновые', 11, 1700.00),
(12, 'Гитара', 'Акустическая', 12, 6500.00), (12, 'Саксофон', 'Альт', 12, 57000.00),
(13, 'Диван', 'Угловой', 13, 24000.00), (13, 'Стул', 'Офисный', 13, 2500.00),
(14, 'Корм для собак', '12 кг', 14, 3200.00), (14, 'Наполнитель кошачий', '5 кг', 14, 890.00),
(15, 'Краски акриловые', '24 цвета', 15, 1600.00), (15, 'Блокнот для эскизов', 'А4', 15, 430.00),

(1, 'Планшет', '10 дюймов', 1, 25000.00), (1, 'Монитор', '24 дюйма', 1, 9000.00),
(2, 'Геймпад', 'Беспроводной', 2, 3500.00), (2, 'Наушники', 'С беспроводным зарядом', 2, 7000.00),
(3, 'Куртка', 'Ветровка', 3, 4500.00), (3, 'Брюки', 'Джинсы темные', 3, 3200.00),
(4, 'Кукла', 'Коллекционная', 4, 3500.00), (4, 'Конструктор', '1000 деталей', 4, 5200.00),
(5, 'Кофе', 'Арабика', 5, 700.00), (5, 'Молоко', '2.5%', 5, 65.00),
(6, 'Лосьон для тела', 'Увлажняющий', 6, 520.00), (6, 'Мыло', 'Натуральное', 6, 180.00),
(7, 'Скакалка', 'ПВХ', 7, 300.00), (7, 'Мяч футбольный', 'Акционный', 7, 2700.00),
(8, 'Отвертка набор', '10 предметов', 8, 1650.00), (8, 'Пила', 'Ручная', 8, 8200.00),
(9, 'Грабли', 'Металлические', 9, 1200.00), (9, 'Садовые ножницы', 'Удобные', 9, 2300.00),
(10, 'Карандаши', 'Цветные, 12 штук', 10, 210.00), (10, 'Клей', 'Для бумаги', 10, 150.00),
(11, 'Автомобильный видеорегистратор', 'HD качество', 11, 4500.00), (11, 'Коврики резиновые', 'Для автомобиля', 11, 1700.00),
(12, 'Синтезатор', '61 клавиша', 12, 38000.00), (12, 'Акустическая гитара', 'Деревянная', 12, 6500.00),
(13, 'Шкаф-купе', '3 секции, зеркало', 13, 33000.00), (13, 'Стул офисный', 'Комфортный', 13, 2500.00),
(14, 'Корм для собак', '12 кг', 14, 3200.00), (14, 'Наполнитель кошачий', '5 кг', 14, 890.00),
(15, 'Палитра красок акриловых', '24 цвета', 15, 1600.00), (15, 'Блокнот для эскизов', 'А4', 15, 430.00);

-- Назначения работников (30)
INSERT INTO marketplace.worker_assignments (worker_id, place_type, place_id, work_id) VALUES
(1, 'shop', 2, 1), (2, 'shop', 4, 2), (3, 'shop', 6, 3), (4, 'shop', 8, 4), (5, 'shop', 10, 5),
(6, 'pvz', 1, 6), (7, 'pvz', 3, 7), (8, 'pvz', 5, 8), (9, 'pvz', 7, 9), (10, 'pvz', 9, 10),
(11, 'shop', 12, 11), (12, 'shop', 14, 12), (13, 'shop', 16, 13), (14, 'shop', 18, 14), (15, 'shop', 20, 15),
(16, 'pvz', 11, 16), (17, 'pvz', 13, 17), (18, 'pvz', 15, 18), (19, 'pvz', 17, 19), (20, 'pvz', 19, 20),
(21, 'shop', 22, 1), (22, 'shop', 24, 2), (23, 'shop', 26, 3), (24, 'shop', 28, 4), (25, 'shop', 30, 5),
(26, 'pvz', 21, 6), (27, 'pvz', 23, 7), (28, 'pvz', 25, 8), (29, 'pvz', 27, 9), (30, 'pvz', 29, 10);

-- Покупки (60)
INSERT INTO marketplace.purchases (item_id, buyer_id, purchase_date, status) VALUES
(1, 1, NOW()-interval '1 day', 'completed'), (2, 2, NOW()-interval '2 day', 'completed'),
(3, 3, NOW()-interval '3 day', 'cancelled'), (4, 4, NOW()-interval '4 day', 'completed'),
(5, 5, NOW()-interval '5 day', 'pending'), (6, 6, NOW()-interval '6 day', 'completed'),
(7, 7, NOW()-interval '7 day', 'completed'), (8, 8, NOW()-interval '8 day', 'cancelled'),
(9, 9, NOW()-interval '9 day', 'completed'), (10, 10, NOW()-interval '10 day', 'completed'),
(11, 11, NOW()-interval '11 day', 'pending'), (12, 12, NOW()-interval '12 day', 'completed'),
(13, 13, NOW()-interval '13 day', 'completed'), (14, 14, NOW()-interval '14 day', 'cancelled'),
(15, 15, NOW()-interval '15 day', 'completed'), (16, 16, NOW()-interval '16 day', 'completed'),
(17, 17, NOW()-interval '17 day', 'pending'), (18, 18, NOW()-interval '18 day', 'completed'),
(19, 19, NOW()-interval '19 day', 'completed'), (20, 20, NOW()-interval '20 day', 'completed'),
(21, 21, NOW()-interval '21 day', 'pending'), (22, 22, NOW()-interval '22 day', 'completed'),
(23, 23, NOW()-interval '23 day', 'completed'), (24, 24, NOW()-interval '24 day', 'cancelled'),
(25, 25, NOW()-interval '25 day', 'completed'), (26, 26, NOW()-interval '26 day', 'completed'),
(27, 27, NOW()-interval '27 day', 'pending'), (28, 28, NOW()-interval '28 day', 'completed'),
(29, 29, NOW()-interval '29 day', 'completed'), (30, 30, NOW()-interval '30 day', 'completed'),
(31, 31, NOW()-interval '31 day', 'pending'), (32, 32, NOW()-interval '32 day', 'completed'),
(33, 33, NOW()-interval '33 day', 'completed'), (34, 34, NOW()-interval '34 day', 'cancelled'),
(35, 35, NOW()-interval '35 day', 'completed'), (36, 36, NOW()-interval '36 day', 'completed'),
(37, 37, NOW()-interval '37 day', 'pending'), (38, 38, NOW()-interval '38 day', 'completed'),
(39, 39, NOW()-interval '39 day', 'completed'), (40, 40, NOW()-interval '40 day', 'completed'),
(41, 41, NOW()-interval '41 day', 'pending'), (42, 42, NOW()-interval '42 day', 'completed'),
(43, 43, NOW()-interval '43 day', 'completed'), (44, 44, NOW()-interval '44 day', 'cancelled'),
(45, 45, NOW()-interval '45 day', 'completed'), (46, 46, NOW()-interval '46 day', 'completed'),
(47, 47, NOW()-interval '47 day', 'pending'), (48, 48, NOW()-interval '48 day', 'completed'),
(49, 49, NOW()-interval '49 day', 'completed'), (50, 50, NOW()-interval '50 day', 'completed'),
(51, 1, NOW()-interval '51 day', 'pending'), (52, 2, NOW()-interval '52 day', 'completed'),
(53, 3, NOW()-interval '53 day', 'completed'), (54, 4, NOW()-interval '54 day', 'cancelled'),
(55, 5, NOW()-interval '55 day', 'completed'), (56, 6, NOW()-interval '56 day', 'completed'),
(57, 7, NOW()-interval '57 day', 'pending'), (58, 8, NOW()-interval '58 day', 'completed'),
(59, 9, NOW()-interval '59 day', 'completed'), (60, 10, NOW()-interval '60 day', 'completed');

-- Заказы (60)
INSERT INTO marketplace.orders (purchase_id, pvz_id, status, order_date) VALUES
(1, 1, 'delivered', NOW()-interval '1 day'), (2, 2, 'created', NOW()-interval '2 day'),
(3, 3, 'cancelled', NOW()-interval '3 day'), (4, 4, 'delivered', NOW()-interval '4 day'),
(5, 5, 'created', NOW()-interval '5 day'), (6, 6, 'delivered', NOW()-interval '6 day'),
(7, 7, 'delivered', NOW()-interval '7 day'), (8, 8, 'cancelled', NOW()-interval '8 day'),
(9, 9, 'delivered', NOW()-interval '9 day'), (10, 10, 'delivered', NOW()-interval '10 day'),
(11, 11, 'created', NOW()-interval '11 day'), (12, 12, 'delivered', NOW()-interval '12 day'),
(13, 13, 'delivered', NOW()-interval '13 day'), (14, 14, 'cancelled', NOW()-interval '14 day'),
(15, 15, 'delivered', NOW()-interval '15 day'), (16, 16, 'delivered', NOW()-interval '16 day'),
(17, 17, 'created', NOW()-interval '17 day'), (18, 18, 'delivered', NOW()-interval '18 day'),
(19, 19, 'delivered', NOW()-interval '19 day'), (20, 20, 'delivered', NOW()-interval '20 day'),
(21, 21, 'created', NOW()-interval '21 day'), (22, 22, 'delivered', NOW()-interval '22 day'),
(23, 23, 'delivered', NOW()-interval '23 day'), (24, 24, 'cancelled', NOW()-interval '24 day'),
(25, 25, 'delivered', NOW()-interval '25 day'), (26, 26, 'delivered', NOW()-interval '26 day'),
(27, 27, 'created', NOW()-interval '27 day'), (28, 28, 'delivered', NOW()-interval '28 day'),
(29, 29, 'delivered', NOW()-interval '29 day'), (30, 30, 'delivered', NOW()-interval '30 day'),
(31, 31, 'created', NOW()-interval '31 day'), (32, 32, 'delivered', NOW()-interval '32 day'),
(33, 33, 'delivered', NOW()-interval '33 day'), (34, 34, 'cancelled', NOW()-interval '34 day'),
(35, 35, 'delivered', NOW()-interval '35 day'), (36, 36, 'delivered', NOW()-interval '36 day'),
(37, 37, 'created', NOW()-interval '37 day'), (38, 38, 'delivered', NOW()-interval '38 day'),
(39, 39, 'delivered', NOW()-interval '39 day'), (40, 40, 'delivered', NOW()-interval '40 day'),
(41, 41, 'created', NOW()-interval '41 day'), (42, 42, 'delivered', NOW()-interval '42 day'),
(43, 43, 'delivered', NOW()-interval '43 day'), (44, 44, 'cancelled', NOW()-interval '44 day'),
(45, 45, 'delivered', NOW()-interval '45 day'), (46, 46, 'delivered', NOW()-interval '46 day'),
(47, 47, 'created', NOW()-interval '47 day'), (48, 48, 'delivered', NOW()-interval '48 day'),
(49, 49, 'delivered', NOW()-interval '49 day'), (50, 50, 'delivered', NOW()-interval '50 day'),
(51, 1, 'created', NOW()-interval '51 day'), (52, 2, 'delivered', NOW()-interval '52 day'),
(53, 3, 'delivered', NOW()-interval '53 day'), (54, 4, 'cancelled', NOW()-interval '54 day'),
(55, 5, 'delivered', NOW()-interval '55 day'), (56, 6, 'delivered', NOW()-interval '56 day');

-- Отзывы (60)
INSERT INTO marketplace.reviews (purchase_id, rating, description) VALUES
(1, 5, 'Отлично!'), (2, 4, 'Хорошо'), (3, 2, 'Плохо'), (4, 3, 'Удовлетворительно'), (5, 1, 'Совсем не понравилось'),
(6, 5, 'Быстрая доставка'), (7, 4, 'Качественный товар'), (8, 2, 'Не работает'), (9, 3, 'Средне'),
(10, 4, 'На высоте'), (11, 3, 'Пересорт'), (12, 5, 'Супер!'), (13, 2, 'Подделка'), (14, 1, 'Хлам'), (15, 5, 'Точно как описано'),
(16, 4, 'Все хорошо'), (17, 3, 'Пойдет'), (18, 4, 'Нормально'), (19, 5, 'Мега круто'), (20, 2, 'Сломалось сразу'),
(21, 5, 'Закажу еще'), (22, 4, 'Достаточно'), (23, 3, 'Можно пользоваться'), (24, 4, 'Советую'), (25, 5, 'Восторг'),
(26, 2, 'Вышло из строя'), (27, 4, 'Быстро привезли'), (28, 3, 'Без эмоций'), (29, 2, 'Батарейки не в комплекте'),
(30, 5, 'Лучший из вариантов'), (31, 1, 'Отвратительно'), (32, 4, 'Можно брать'), (33, 5, 'Топ!'), (34, 2, 'Ожидал большего'),
(35, 3, 'Нормальный сервис'), (36, 4, 'Оперативно'), (37, 2, 'Упаковка плохая'), (38, 3, 'Вижу недостатки'),
(39, 5, 'Понравилось'), (40, 4, 'Могу рекомендовать'), (41, 3, 'Так себе'), (42, 2, 'Бифштекс сырой'),
(43, 5, 'Сделано с душой'), (44, 5, 'Удачный выбор'), (45, 2, 'Ошибка доставки'), (46, 3, 'Забыли подарочек'),
(47, 5, 'Товар на 5'), (48, 4, 'Адекватно'), (49, 3, 'Проблемы с гарантийкой'), (50, 4, 'Надежно'),
(51, 2, 'Техподдержка тормозит'), (52, 3, 'Ждал быстрее'), (53, 4, 'Оперативная отправка'),
(54, 5, 'Замечательно'), (55, 2, 'Брак на упаковке'), (56, 3, 'Долго ждал'), (57, 4, 'Советуем друзьям'),
(58, 5, 'Буду покупать еще'), (59, 2, 'Опоздали'), (60, 4, 'Просто отлично');
```
