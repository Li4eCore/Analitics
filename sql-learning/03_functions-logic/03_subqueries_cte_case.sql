-- ============================================================
-- Подзапросы, CTE, CASE, COALESCE, NULLIF, EXISTS, ANY, ALL
-- БД: Nordwind (учебная база, PostgreSQL/MySQL)
-- ============================================================


-- === ПОДЗАПРОСЫ ===

-- Скалярный подзапрос в WHERE: сравнение со средним значением
SELECT
    product_id,
    product_name,
    quantity_per_unit,
    unit_price
FROM products
WHERE product_name LIKE 'S%' AND unit_price > (
    SELECT AVG(unit_price) FROM products
)
ORDER BY product_id;


-- Подзапрос с агрегатом внутри вычисления (минимальная цена + запас)
SELECT
    product_id,
    product_name,
    unit_price
FROM products
WHERE unit_price < (
    SELECT MIN(unit_price) + 5 FROM products
)
ORDER BY unit_price DESC;


-- Подзапрос как вычисляемый столбец: сколько докупить до максимального остатка
SELECT
    product_id,
    product_name,
    units_in_stock,
    (SELECT MAX(units_in_stock) FROM products) - units_in_stock AS count_order
FROM products p
WHERE (SELECT MAX(units_in_stock) FROM products) - units_in_stock != 0
ORDER BY count_order, product_name
LIMIT 10;


-- Подзапрос в WHERE через MAX: товары из самого последнего заказа
SELECT
    p.product_name
FROM products p
JOIN order_details od
    ON p.product_id = od.product_id
WHERE order_id = (SELECT MAX(od2.order_id) FROM order_details od2)
ORDER BY p.product_name;


-- === CTE ===

-- CTE поверх UNION нескольких таблиц с одинаковой структурой
WITH all_tables AS (
    SELECT * FROM sales_1
    UNION
    SELECT * FROM sales_2
    UNION
    SELECT * FROM sales_3
)
SELECT *
FROM all_tables
ORDER BY month_num;


-- CTE с эмуляцией FULL JOIN через UNION двух LEFT/RIGHT JOIN
WITH total AS (
    SELECT e.id, e.last_name, t.task_name, t.employee_id
    FROM employees e
    LEFT JOIN tasks t ON e.id = t.employee_id
    UNION
    SELECT e.id, e.last_name, t.task_name, t.employee_id
    FROM employees e
    RIGHT JOIN tasks t ON e.id = t.employee_id
)
SELECT last_name, task_name
FROM total
ORDER BY last_name DESC, task_name;


-- === CASE ===

-- Многоступенчатый CASE: категоризация товаров по цене
SELECT
    product_name,
    unit_price,
    CASE
        WHEN unit_price >= 50 THEN 'Люкс'
        WHEN unit_price >= 25 THEN 'Премиум'
        WHEN unit_price >= 15 THEN 'Масс маркет'
        ELSE 'Эконом'
    END AS level_product
FROM products p
ORDER BY p.product_name
LIMIT 5;


-- CASE для замены NULL на текстовую заглушку
SELECT
    s.company_name,
    CASE
        WHEN s.region IS NOT NULL THEN s.region
        ELSE 'Region not filled'
    END AS full_region
FROM suppliers s
ORDER BY company_name;


-- CASE + GROUP BY: категоризация прямо в группировке
SELECT
    CASE
        WHEN shipped_date <= required_date THEN 'Отгружено без задержки'
        ELSE 'Отгружено с задержкой'
    END AS shipping_status,
    COUNT(order_id) AS cnt_orders
FROM orders
GROUP BY shipping_status
ORDER BY cnt_orders DESC;


-- === COALESCE ===

-- COALESCE в условии фильтрации
SELECT company_name
FROM suppliers
WHERE COALESCE(region, 'Other') != 'Québec'
ORDER BY company_name;


-- COALESCE для замены NULL в выводимом столбце
SELECT
    company_name,
    COALESCE(region, 'Region not filled') AS full_region
FROM suppliers
ORDER BY company_name;


-- === NULLIF ===

-- NULLIF защищает от деления на ноль + приведение типа
SELECT
    last_name,
    total_score,
    exams_count,
    CAST(ROUND(NULLIF(total_score / exams_count, 0)) AS UNSIGNED) AS avg_score_exams
FROM students
ORDER BY last_name;


-- === EXISTS ===

-- EXISTS: поставщики, у которых есть товары нужной категории
SELECT company_name
FROM suppliers s
WHERE EXISTS (
    SELECT *
    FROM products p
    WHERE p.supplier_id = s.supplier_id AND p.category_id = 1
)
ORDER BY company_name;


-- NOT EXISTS: обратный случай — поставщики без товаров этой категории
SELECT company_name
FROM suppliers s
WHERE NOT EXISTS (
    SELECT p.category_id
    FROM products p
    WHERE p.supplier_id = s.supplier_id AND p.category_id = 1
)
ORDER BY company_name;


-- === ANY / ALL ===

-- ANY: зарплата выше хотя бы одной зарплаты в другом отделе
SELECT employee_name
FROM employees
WHERE department = 'HR' AND salary > ANY (
    SELECT salary FROM employees WHERE department = 'IT'
)
ORDER BY employee_name;


-- ALL: зарплата выше всех зарплат в другом отделе
SELECT employee_name
FROM employees
WHERE department = 'IT' AND salary > ALL (
    SELECT salary FROM employees WHERE department = 'HR'
)
ORDER BY employee_name;


-- === КОМБИНИРОВАННЫЕ ПРИМЕРЫ ===

-- JOIN + BETWEEN по датам + HAVING: крупные покупатели за конкретный период
SELECT
    c.company_name
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN order_details od
    ON od.order_id = o.order_id
WHERE o.order_date BETWEEN '1996-09-01' AND '1996-11-29'
GROUP BY c.company_name
HAVING SUM(od.quantity) > 250
ORDER BY c.company_name;


-- EXTRACT(YEAR) + фильтр по непустому полю + GROUP BY
SELECT
    c.company_name,
    COUNT(o.order_id) AS cnt_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE EXTRACT(YEAR FROM o.order_date) = 1997 AND c.fax IS NOT NULL
GROUP BY c.company_name
ORDER BY c.company_name;


-- CTE поверх UNION трёх таблиц + GROUP_CONCAT по регионам
WITH all_table AS (
    SELECT * FROM us_states_1
    UNION
    SELECT * FROM us_states_2
    UNION
    SELECT * FROM us_states_3
)
SELECT
    state_region,
    GROUP_CONCAT(state_name ORDER BY state_name SEPARATOR ', ') AS list_state_name
FROM all_table
GROUP BY state_region
ORDER BY state_region;
