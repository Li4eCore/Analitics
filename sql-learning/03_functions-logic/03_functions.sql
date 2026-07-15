-- ============================================================
-- Функции в SQL: текстовые, числовые, даты
-- БД: Nordwind (учебная база, PostgreSQL/MySQL)
-- ============================================================


-- === ТЕКСТОВЫЕ ФУНКЦИИ ===

-- CONCAT_WS: склейка строк через разделитель, пропуская NULL
SELECT
    category_id,
    CONCAT_WS(': ', category_name, description) AS category_name_description
FROM categories;


-- LEFT / RIGHT: первые / последние N символов строки
SELECT
    category_name,
    LEFT(category_name, 3) AS left_category_name,
    RIGHT(category_name, 3) AS right_category_name
FROM categories
ORDER BY category_name;


-- LOWER / UPPER: регистр строки
SELECT
    category_name,
    LOWER(category_name) AS lower_category_name,
    UPPER(category_name) AS upper_category_name
FROM categories
ORDER BY category_name;


-- SUBSTRING: извлечение части строки с позиции на заданную длину
SELECT
    category_name,
    SUBSTRING(category_name FROM 3 FOR 1) AS symbol
FROM categories
ORDER BY category_name;


-- LENGTH: длина строки
SELECT
    category_name,
    LENGTH(category_name) AS length_category_name
FROM categories
ORDER BY category_name;


-- POSITION: номер первого вхождения символа/подстроки
SELECT
    category_name,
    POSITION('c' IN category_name) AS symbol_category_name
FROM categories
ORDER BY category_name;


-- === ЧИСЛОВЫЕ ФУНКЦИИ ===

-- ROUND: округление до заданного количества знаков
SELECT
    product_name,
    unit_price,
    ROUND(unit_price, 1) AS r_unit_price
FROM products
WHERE unit_price BETWEEN 16 AND 18
ORDER BY product_name;


-- CEILING: округление вверх до целого
SELECT
    product_name,
    unit_price,
    CEILING(unit_price) AS c_unit_price
FROM products
WHERE unit_price BETWEEN 30 AND 31.5
ORDER BY product_name;


-- FLOOR: округление вниз до целого
SELECT
    product_name,
    unit_price,
    FLOOR(unit_price) AS f_unit_price
FROM products
WHERE unit_price BETWEEN 9 AND 10
ORDER BY product_name;


-- === ФУНКЦИИ ДАТ ===

-- YEAR / MONTH / DAY: извлечение частей даты
SELECT last_name, YEAR(birth_date) AS birth_year
FROM employees
ORDER BY last_name;

SELECT last_name, MONTH(birth_date) AS birth_month
FROM employees
ORDER BY last_name;

SELECT last_name, DAY(birth_date) AS birth_day
FROM employees
ORDER BY last_name;


-- MONTHNAME / DAYNAME: название месяца / дня недели текстом
SELECT last_name, MONTHNAME(hire_date) AS hire_monthname
FROM employees
ORDER BY last_name;

SELECT last_name, DAYNAME(birth_date) AS birth_day_name
FROM employees
ORDER BY last_name;


-- QUARTER: номер квартала по дате
SELECT last_name, QUARTER(hire_date) AS hire_qtr
FROM employees
ORDER BY last_name;


-- WEEKOFYEAR: номер недели в году
SELECT last_name, WEEKOFYEAR(hire_date) AS hire_number_week
FROM employees
ORDER BY last_name;


-- === КОМБИНИРОВАННЫЕ ПРИМЕРЫ ===

-- DATEDIFF + GROUP BY: страны, где отгрузка задержалась больше 10 дней
SELECT
    ship_country,
    COUNT(order_id) AS cnt_orders
FROM orders
WHERE DATEDIFF(shipped_date, order_date) > 10
GROUP BY ship_country
ORDER BY ship_country
LIMIT 5;


-- DATEDIFF для расчёта возраста на момент приёма на работу
SELECT
    last_name,
    FLOOR(DATEDIFF(hire_date, birth_date) / 365) AS age_hire
FROM employees
ORDER BY last_name;


-- CONCAT_WS: собираем читаемое предложение из нескольких полей и функции даты
SELECT
    last_name,
    CONCAT_WS(' ', first_name, last_name, 'принят(а) на работу в', YEAR(hire_date)) AS description_hire
FROM employees
ORDER BY last_name;


-- Группировка по месяцу и году одновременно — динамика заказов
SELECT
    MONTHNAME(order_date) AS name_month,
    YEAR(order_date) AS name_year,
    COUNT(order_id) AS cnt_orders
FROM orders
GROUP BY MONTHNAME(order_date), YEAR(order_date)
ORDER BY cnt_orders;
