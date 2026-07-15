# Соединение и объединение таблиц

БД: Nordwind (учебная база, PostgreSQL/MySQL)

---

## INNER JOIN — базовое соединение

```sql
SELECT
    o.order_id,
    o.order_date,
    o.ship_country,
    e.last_name
FROM orders o
INNER JOIN employees e
    ON o.employee_id = e.employee_id;
```

---

## JOIN трёх таблиц + фильтр по нескольким условиям

```sql
SELECT
    o.order_id,
    o.customer_id,
    e.last_name,
    s.company_name
FROM orders o
JOIN shippers s
    ON o.ship_via = s.shipper_id
JOIN employees e
    ON o.employee_id = e.employee_id
WHERE e.last_name = 'King' AND s.company_name = 'Federal Shipping'
ORDER BY o.order_id;
```

---

## LEFT JOIN — все строки левой таблицы

```sql
SELECT
    e.employee_id,
    e.employee_name,
    d.department_name
FROM employees e
LEFT JOIN departments d
    ON e.department_id = d.department_id
ORDER BY e.employee_id;
```

---

## RIGHT JOIN — поиск "хвостов" без пары

Товары без указанной категории — эквивалент "чего не хватает" через отсутствие связи.

```sql
SELECT
    p.product_name
FROM categories c
RIGHT JOIN products p
    ON c.category_id = p.category_id
WHERE category_name IS NULL;
```

---

## CROSS JOIN — декартово произведение

Каждая строка левой таблицы соединяется с каждой строкой правой.

```sql
SELECT soup_name, main_course_name
FROM soups
CROSS JOIN main_courses
ORDER BY soup_name, main_course_name;
```

---

## UNION ALL — объединение с сохранением дублей

```sql
SELECT * FROM sales_1
UNION ALL
SELECT * FROM sales_2
UNION ALL
SELECT * FROM sales_3;
```

## UNION — объединение, только уникальные строки

```sql
SELECT * FROM sales_1
UNION
SELECT * FROM sales_2
UNION
SELECT * FROM sales_3;
```

---

## JOIN + фильтр по цене и исключение списка (NOT IN)

```sql
SELECT
    p.product_name,
    c.category_name,
    p.unit_price
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
WHERE p.unit_price > 40 AND p.supplier_id NOT IN (7, 12)
ORDER BY p.unit_price DESC;
```

---

## JOIN четырёх таблиц с русскими алиасами

```sql
SELECT
    o.order_id AS 'Заказ',
    e.last_name AS 'Сотрудник',
    c.company_name AS 'Покупатель',
    s.company_name AS 'Доставка'
FROM orders o
JOIN employees e
    ON o.employee_id = e.employee_id
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN shippers s
    ON o.ship_via = s.shipper_id
WHERE e.last_name NOT IN ('Buchanan', 'Fuller')
ORDER BY o.order_id
LIMIT 5;
```

---

## LEFT JOIN + GROUP BY + COUNT

Сколько товаров в каждой категории, включая категории без единого товара.

```sql
SELECT
    c.category_name,
    COUNT(p.product_id) AS cnt_products
FROM categories c
LEFT JOIN products p
    ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY cnt_products DESC, c.category_name;
```

---

## LEFT JOIN + HAVING

Покупатели минимум с одним заказом.

```sql
SELECT
    c.company_name AS "Покупатель",
    COUNT(o.order_id) AS "Количество заказов"
FROM customers c
LEFT JOIN orders o
    ON o.customer_id = c.customer_id
GROUP BY c.company_name
HAVING COUNT(o.order_id) > 0
ORDER BY c.company_name
LIMIT 5;
```

---

## Комбинация RIGHT JOIN + LEFT JOIN в одном запросе

```sql
SELECT
    c.company_name
FROM orders o
RIGHT JOIN order_details od
    ON o.order_id = od.order_id
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.company_name
HAVING SUM(od.quantity) <= 25 AND COUNT(od.quantity) != 0
ORDER BY c.company_name;
```
