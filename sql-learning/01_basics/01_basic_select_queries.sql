-- ============================================================
-- Базовые SELECT-запросы
-- БД: Nordwind (учебная база, PostgreSQL/MySQL)
-- ============================================================


-- Выбор конкретных столбцов с русскими алиасами через AS
SELECT
    product_name AS 'Наименование продукта',
    category_id AS 'Категория продукта',
    unit_price AS 'Цена продукта'
FROM products;


-- Вычисляемый столбец: считаем сумму по позиции заказа на лету
SELECT
    order_id,
    product_id,
    unit_price * quantity AS amount
FROM order_details;


-- Фильтрация по диапазону значений (BETWEEN) и списку категорий (IN) одновременно
SELECT
    product_id,
    product_name,
    unit_price
FROM products
WHERE (unit_price BETWEEN 30 AND 40)
  AND supplier_id IN (3, 5, 7)
ORDER BY unit_price DESC;


-- Поиск по шаблону: LIKE с масками % (любое кол-во символов) и _ (один символ)
SELECT product_id, product_name, category_id
FROM products
WHERE product_name LIKE 'G%c_';


-- Поиск строк с пустым значением поля (IS NULL)
SELECT order_id, customer_id
FROM orders
WHERE ship_region IS NULL;


-- Условие ИЛИ по нескольким значениям одного столбца
SELECT order_id, order_date, shipped_date, ship_country
FROM orders
WHERE ship_country = 'USA' OR ship_country = 'Mexico';


-- Сортировка по нескольким столбцам с разным направлением
SELECT supplier_id, category_id, product_name
FROM products
WHERE supplier_id IN (1, 2)
ORDER BY supplier_id, category_id, product_name DESC;


-- Топ-5 самых дорогих позиций заказов: сортировка по вычисляемому столбцу + LIMIT
SELECT order_id, product_id, unit_price * quantity AS amount
FROM order_details
ORDER BY amount DESC, order_id DESC
LIMIT 5;


-- Группировка с подсчётом и фильтром по маске страны (LIKE + GROUP BY + COUNT)
SELECT ship_country, COUNT(order_id) AS cnt_orders
FROM orders
WHERE ship_country LIKE 'S%'
GROUP BY ship_country
ORDER BY cnt_orders DESC;


-- Фильтрация уже сгруппированных данных через HAVING
SELECT ship_country, COUNT(order_id) AS cnt_orders
FROM orders
GROUP BY ship_country
HAVING COUNT(order_id) > 25
ORDER BY ship_country;


-- HAVING с диапазоном (BETWEEN применённый к агрегату)
SELECT ship_city, COUNT(order_id) AS cnt_orders
FROM orders
GROUP BY ship_city
HAVING COUNT(order_id) BETWEEN 5 AND 6
ORDER BY cnt_orders DESC, ship_city;


-- Сумма по конкретному заказу — агрегат без группировки, с фильтром по одному id
SELECT SUM(unit_price * quantity) AS sum_order_10425
FROM order_details
WHERE order_id = 10425;


-- Максимальная цена товара по каждому поставщику из заданного списка
SELECT supplier_id, MAX(unit_price) AS max_price
FROM products
WHERE supplier_id IN (1, 3, 5)
GROUP BY supplier_id
ORDER BY supplier_id;
