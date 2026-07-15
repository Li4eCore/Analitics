-- ============================================================
-- Оконные функции
-- БД: Nordwind + учебные таблицы (category_amount, swim, employee и др.)
-- ============================================================


-- === РАНЖИРУЮЩИЕ ФУНКЦИИ ===

-- DENSE_RANK: ранг без пропусков при равных значениях
SELECT
    *,
    DENSE_RANK() OVER (ORDER BY amount DESC) AS dns_rank
FROM category_amount
ORDER BY dns_rank;


-- ROW_NUMBER: уникальный порядковый номер, сортировка по двум столбцам
SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY amount DESC, category_name) AS row_num
FROM category_amount
ORDER BY row_num;


-- NTILE: деление результата на 5 равных групп по остатку на складе
SELECT
    NTILE(5) OVER (ORDER BY units_in_stock DESC) AS group_product,
    product_name,
    category_id,
    unit_price,
    units_in_stock
FROM products
ORDER BY product_name
LIMIT 10;


-- DENSE_RANK + PARTITION BY + CTE: самый дорогой товар в каждой категории
WITH w AS (
    SELECT
        DENSE_RANK() OVER (PARTITION BY c.category_name ORDER BY p.unit_price DESC) AS dr,
        c.category_name,
        p.product_name,
        p.unit_price
    FROM products p
    JOIN categories c
        ON p.category_id = c.category_id
)
SELECT category_name, product_name, unit_price
FROM w
WHERE dr = 1
ORDER BY category_name;


-- DENSE_RANK + PARTITION BY: самая дешёвая доставка у каждого перевозчика
WITH f AS (
    SELECT
        s.company_name,
        o.ship_via,
        o.freight,
        DENSE_RANK() OVER (PARTITION BY o.ship_via ORDER BY o.freight) AS fsv
    FROM orders o
    JOIN shippers s
        ON o.ship_via = s.shipper_id
)
SELECT company_name, freight
FROM f
WHERE fsv = 1
ORDER BY company_name;


-- === АГРЕГИРУЮЩИЕ ОКОННЫЕ ФУНКЦИИ ===

-- AVG OVER PARTITION: среднее по группе рядом с каждым результатом + отклонение
SELECT
    lastname,
    subject,
    style,
    res,
    AVG(res) OVER (PARTITION BY style) AS avg_style,
    ROUND(AVG(res) OVER (PARTITION BY style) - res, 3) AS time_avg
FROM swim
ORDER BY style, lastname;


-- AVG OVER PARTITION по одному признаку (снят с продажи / нет)
SELECT
    product_name,
    category_id,
    unit_price,
    ROUND(AVG(unit_price) OVER (PARTITION BY discontinued), 3) AS avg_unit_price
FROM products
WHERE discontinued = 0
ORDER BY product_name
LIMIT 5;


-- AVG OVER PARTITION по категории — та же логика, другой разрез
SELECT
    product_name,
    category_id,
    unit_price,
    ROUND(AVG(unit_price) OVER (PARTITION BY category_id), 3) AS avg_unit_price
FROM products
WHERE discontinued = 0
ORDER BY product_name
LIMIT 5;


-- CTE + AVG OVER PARTITION: отклонение суммы заказа от среднего по клиенту
WITH OrderTotals AS (
    SELECT
        o.order_id,
        o.customer_id,
        SUM(od.unit_price * od.quantity) AS total_revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_id, o.customer_id
)
SELECT
    order_id,
    customer_id,
    ROUND(total_revenue, 2) AS order_revenue,
    ROUND(AVG(total_revenue) OVER (PARTITION BY customer_id), 2) AS avg_cus_ord,
    ROUND(total_revenue - AVG(total_revenue) OVER (PARTITION BY customer_id), 2) AS diff_rev_avg
FROM OrderTotals
ORDER BY customer_id, order_id
LIMIT 10;


-- SUM OVER() без PARTITION: доля товара в общей выручке (окно на всю таблицу)
WITH ProductRevenues AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(od.unit_price * od.quantity) AS total_revenue
    FROM products p
    JOIN order_details od ON p.product_id = od.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_name,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) AS share_of_sales
FROM ProductRevenues
ORDER BY share_of_sales DESC
LIMIT 5;


-- === ФУНКЦИИ СМЕЩЕНИЯ ===

-- LAG / LEAD: зарплата предыдущего и следующего сотрудника в отсортированном списке
SELECT
    lastname,
    department,
    city,
    LAG(salary) OVER (ORDER BY salary, lastname) AS prv_salary,
    salary,
    LEAD(salary) OVER (ORDER BY salary, lastname) AS nxt_salary
FROM employee
LIMIT 8
OFFSET 1;


-- FIRST_VALUE / LAST_VALUE с явным фреймом на весь раздел (UNBOUNDED)
SELECT
    lastname,
    department,
    salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department ORDER BY salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS mn_sal_dep,
    LAST_VALUE(salary) OVER (
        PARTITION BY department ORDER BY salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS mx_sal_dep,
    FIRST_VALUE(lastname) OVER (
        PARTITION BY department ORDER BY salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS mn_lstn,
    LAST_VALUE(lastname) OVER (
        PARTITION BY department ORDER BY salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS mx_lstn
FROM employee
ORDER BY department;
