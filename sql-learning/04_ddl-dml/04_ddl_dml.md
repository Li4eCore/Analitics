# Операторы группы DDL и DML

БД: Nordwind (учебная база, PostgreSQL/MySQL)

---

## DML: INSERT

**Добавление новой строки с явным перечислением столбцов.**
```sql
INSERT INTO shippers (shipper_id, company_name, phone)
VALUES (7, 'Express', '777-777-777');
```

**Добавление строки со всеми столбцами таблицы.**
```sql
INSERT INTO products (
    product_id, product_name, supplier_id, category_id, quantity_per_unit,
    unit_price, units_in_stock, units_on_order, reorder_level, discontinued
)
VALUES (
    78, 'Klosterbier', 12, 101, '24 - 0.5 l bottles',
    7.75, 125, 0, 25, 0
);
```

---

## DML: UPDATE

**Обновление одного столбца по условию на первичный ключ.**
```sql
UPDATE shippers
SET company_name = 'Speedy DHL'
WHERE shipper_id = 5;
```

**Обновление нескольких столбцов сразу одним запросом.**
```sql
UPDATE products
SET
    product_name = 'Chai-Chai',
    supplier_id = 1,
    quantity_per_unit = '100 boxes x 100 bags'
WHERE product_id = 1;
```
