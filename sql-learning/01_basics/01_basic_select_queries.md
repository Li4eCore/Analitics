# Базовые SELECT-запросы

БД: Nordwind (учебная база, PostgreSQL/MySQL)

---

## Алиасы столбцов

Выбор конкретных столбцов с русскими алиасами через `AS`.

```sql
SELECT
    product_name AS 'Наименование продукта',
    category_id AS 'Категория продукта',
    unit_price AS 'Цена продукта'
FROM products;
```

---

## Вычисляемый столбец

Считаем сумму по позиции заказа на лету, без хранения в таблице.

```sql
SELECT
    order_id,
    product_id,
    unit_price * quantity AS amount
FROM order_details;
```

---

## Комбинация условий: BETWEEN + IN

Фильтрация по диапазону значений и списку категорий одновременно.

```sql
SELECT
    product_id,
    product_name,
    unit_price
FROM products
WHERE (unit_price BETWEEN 30 AND 40)
  AND supplier_id IN (3, 5, 7)
ORDER BY unit_price DESC;
```

---

## Поиск по шаблону (LIKE)

`%` — любое количество символов, `_` — ровно один символ.

```sql
SELECT product_id, product_name, category_id
FROM products
WHERE product_name LIKE 'G%c_';
```

---

## Поиск пустых значений (IS NULL)

```sql
SELECT order_id, customer_id
FROM orders
WHERE ship_region IS NULL;
```

---

## Условие ИЛИ

Несколько допустимых значений одного столбца.

```sql
SELECT order_id, order_date, shipped_date, ship_country
FROM orders
WHERE ship_country = 'USA' OR ship_country = 'Mexico';
```

---

## Сортировка по нескольким столбцам

Разное направление сортировки для разных столбцов в одном запросе.

```sql
SELECT supplier_id, category_id, product_name
FROM products
WHERE supplier_id IN (1, 2)
ORDER BY supplier_id, category_id, product_name DESC;
```

---

## Топ-N по вычисляемому столбцу

Сортировка по результату выражения + `LIMIT`.

```sql
SELECT order_id, product_id, unit_price * quantity AS amount
FROM order_details
ORDER BY amount DESC, order_id DESC
LIMIT 5;
```

---

## Группировка с подсчётом и фильтром по маске

`LIKE` совмещённый с `GROUP BY` и `COUNT`.

```sql
SELECT ship_country, COUNT(order_id) AS cnt_orders
FROM orders
WHERE ship_country LIKE 'S%'
GROUP BY ship_country
ORDER BY cnt_orders DESC;
```

---

## HAVING — фильтрация после группировки

```sql
SELECT ship_country, COUNT(order_id) AS cnt_orders
FROM orders
GROUP BY ship_country
HAVING COUNT(order_id) > 25
ORDER BY ship_country;
```

---

## HAVING с диапазоном

`BETWEEN`, применённый к результату агрегатной функции.

```sql
SELECT ship_city, COUNT(order_id) AS cnt_orders
FROM orders
GROUP BY ship_city
HAVING COUNT(order_id) BETWEEN 5 AND 6
ORDER BY cnt_orders DESC, ship_city;
```

---

## Агрегат без группировки

Сумма по одному конкретному заказу — фильтр по `id`, без `GROUP BY`.

```sql
SELECT SUM(unit_price * quantity) AS sum_order_10425
FROM order_details
WHERE order_id = 10425;
```

---

## MAX по группе с фильтром списком

Максимальная цена товара по каждому поставщику из заданного списка.

```sql
SELECT supplier_id, MAX(unit_price) AS max_price
FROM products
WHERE supplier_id IN (1, 3, 5)
GROUP BY supplier_id
ORDER BY supplier_id;
```
