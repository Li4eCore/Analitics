# Шпаргалка по SQL

Сжатая версия конспекта — только синтаксис, суть и те моменты,
на которых реально спотыкались.

---

## Порядок выполнения запроса (не порядок написания!)

```
FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT → OFFSET
```
Именно поэтому `HAVING` не видит алиасы из `SELECT` (выполняется раньше),
а `ORDER BY` — видит (выполняется позже).

---

## SELECT, WHERE, ORDER BY

```sql
SELECT столбец1, столбец2
FROM таблица
WHERE условие
ORDER BY столбец [ASC|DESC]
LIMIT n OFFSET m
```

Операторы сравнения в WHERE: `= > < >= <= != IN() BETWEEN IS NULL LIKE`

---

## WHERE vs HAVING

| | WHERE | HAVING |
|---|---|---|
| Когда работает | до группировки | после группировки |
| Что фильтрует | отдельные строки | уже готовые группы |
| Агрегатные функции | нельзя | обычно используется |

```sql
-- WHERE: до группировки, по отдельным строкам
SELECT c.name, SUM(o.amount)
FROM customers c JOIN orders o ON c.id = o.customer_id
WHERE o.amount > 1000
GROUP BY c.name

-- HAVING: после группировки, по агрегату
SELECT c.name, SUM(o.amount) AS total
FROM customers c JOIN orders o ON c.id = o.customer_id
GROUP BY c.name
HAVING SUM(o.amount) > 5000   -- алиас total здесь использовать нельзя
```

---

## JOIN — виды

```sql
FROM customers c
JOIN orders o ON c.id = o.customer_id   -- INNER JOIN по умолчанию
```

- **INNER JOIN** — только строки, у которых есть совпадение в обеих таблицах
- **LEFT JOIN** — все строки левой таблицы + совпадения справа (нет совпадения → NULL)
- **RIGHT JOIN** — зеркально LEFT JOIN
- **FULL OUTER JOIN** — все строки из обеих таблиц
- **CROSS JOIN** — декартово произведение (каждая с каждой)

---

## GROUP BY и агрегатные функции

```sql
SELECT c.name, COUNT(o.id) AS orders_count, SUM(o.amount) AS total
FROM customers c JOIN orders o ON c.id = o.customer_id
GROUP BY c.name
```
`MIN MAX AVG SUM COUNT(*) COUNT(столбец)` — последний игнорирует NULL,
`COUNT(*)` считает все строки без исключений.

Правило: если столбец в SELECT без агрегатной функции — он обязан быть в GROUP BY.

---

## Подзапросы

```sql
-- скалярный / табличный подзапрос
SELECT name FROM customers
WHERE id IN (SELECT customer_id FROM orders WHERE amount > 40000)

-- EXISTS — проверяет, есть ли хоть одна строка в подзапросе
SELECT * FROM customers c
WHERE EXISTS (SELECT * FROM orders o WHERE c.id = o.customer_id)
```

---

## CTE (WITH)

```sql
WITH totals AS (
    SELECT customer_id, SUM(amount) AS total
    FROM orders
    GROUP BY customer_id
)
SELECT * FROM totals WHERE total > (SELECT AVG(total) FROM totals)
```
Живёт только в рамках одного запроса. От подзапроса отличается не
возможностями, а читаемостью — сложный запрос раскладывается на именованные шаги.

---

## Оконные функции

**Главное отличие от GROUP BY:** строки не схлопываются — каждая остаётся
на месте, просто рядом добавляется агрегат по её партиции.

```sql
SELECT name, department, salary,
       AVG(salary) OVER (PARTITION BY department) AS avg_dept_salary
FROM employees
```

**Ранжирующие функции — в чём разница:**

| Функция | Одинаковые значения | Пропуски после повтора |
|---|---|---|
| `ROW_NUMBER()` | разные номера подряд (1,2,3,4) | — |
| `RANK()` | одинаковый ранг (1,2,2,4) | да, пропускает |
| `DENSE_RANK()` | одинаковый ранг (1,2,2,3) | нет, без пропуска |

```sql
SELECT name, department, salary,
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rnk
FROM employees
```

**Функции смещения:** `LAG()` — значение из предыдущей строки,
`LEAD()` — из следующей, `FIRST_VALUE()`/`LAST_VALUE()` — первая/последняя в окне.

---

## CASE, COALESCE, NULLIF

```sql
-- CASE: условная логика
SELECT name,
  CASE
    WHEN salary > 100000 THEN 'высокая'
    WHEN salary > 70000 THEN 'средняя'
    ELSE 'низкая'
  END AS salary_level
FROM employees

-- COALESCE: первое не-NULL значение из списка
SELECT COALESCE(fax, phone, 'нет контакта') AS contact FROM customers

-- NULLIF: возвращает NULL, если два значения равны (иначе первое)
SELECT NULLIF(units_in_stock, 0) FROM products
```

---

## Типы данных (кратко)

- Целые: `smallint integer bigint`
- Точные дробные: `numeric` (для денег — всегда он)
- Текст: `char varchar text`
- Дата/время: `date timestamp time interval`
- Приведение типов: `CAST(expr AS type)` или `expr::type` (только PostgreSQL)

---

## Ограничения (constraints)

`PRIMARY KEY` `FOREIGN KEY` `UNIQUE` `CHECK` `NOT NULL`

```sql
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES customers;
```

---

## Частые ошибки (из практики)

1. `HAVING` не видит алиасы из `SELECT` — нужно повторять всё выражение
   (`HAVING SUM(amount) > 5000`, не `HAVING total > 5000`)
2. `WHERE` не принимает агрегатные функции — для этого есть `HAVING`
3. `RANK()` оставляет "дыры" в номерах при равных значениях, `DENSE_RANK()` — нет
4. GROUP BY схлопывает строки, оконная функция — нет
