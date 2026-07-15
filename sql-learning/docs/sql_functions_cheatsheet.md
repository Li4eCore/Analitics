# Шпаргалка по функциям SQL

| Функция | Для чего нужна | Синтаксис | Пример |
|---|---|---|---|
| **Агрегатные функции** ||||
| `COUNT(*)` | Считает все строки в группе/таблице | `COUNT(*)` | `SELECT COUNT(*) FROM orders` |
| `COUNT(col)` | Считает строки, где значение не NULL | `COUNT(столбец)` | `SELECT COUNT(phone) FROM customers` |
| `SUM()` | Сумма значений | `SUM(столбец)` | `SELECT SUM(amount) FROM orders` |
| `AVG()` | Среднее значение | `AVG(столбец)` | `SELECT AVG(salary) FROM employees` |
| `MIN()` | Наименьшее значение | `MIN(столбец)` | `SELECT MIN(price) FROM products` |
| `MAX()` | Наибольшее значение | `MAX(столбец)` | `SELECT MAX(price) FROM products` |
| `STRING_AGG()` | Склеивает строки группы через разделитель | `STRING_AGG(столбец, 'разделитель')` | `SELECT STRING_AGG(name, ', ') FROM customers` |
| **Оконные функции — агрегирующие** ||||
| `SUM() OVER()` | Сумма без схлопывания строк | `SUM(col) OVER(PARTITION BY ...)` | `SUM(salary) OVER(PARTITION BY department)` |
| `AVG() OVER()` | Среднее по партиции, строки видны все | `AVG(col) OVER(PARTITION BY ...)` | `AVG(salary) OVER(PARTITION BY department)` |
| **Оконные функции — ранжирующие** ||||
| `ROW_NUMBER()` | Уникальный номер строки подряд, без повторов | `ROW_NUMBER() OVER(ORDER BY ...)` | `ROW_NUMBER() OVER(ORDER BY salary DESC)` |
| `RANK()` | Ранг с пропуском мест при равных значениях | `RANK() OVER(ORDER BY ...)` | `RANK() OVER(PARTITION BY dept ORDER BY salary DESC)` |
| `DENSE_RANK()` | Ранг без пропуска мест при равных значениях | `DENSE_RANK() OVER(ORDER BY ...)` | `DENSE_RANK() OVER(ORDER BY salary DESC)` |
| `NTILE(n)` | Делит результат на n групп | `NTILE(n) OVER(ORDER BY ...)` | `NTILE(4) OVER(ORDER BY salary)` |
| **Оконные функции — смещения** ||||
| `LAG()` | Значение из предыдущей строки | `LAG(col) OVER(ORDER BY ...)` | `LAG(amount) OVER(ORDER BY order_date)` |
| `LEAD()` | Значение из следующей строки | `LEAD(col) OVER(ORDER BY ...)` | `LEAD(amount) OVER(ORDER BY order_date)` |
| `FIRST_VALUE()` | Первое значение в окне | `FIRST_VALUE(col) OVER(ORDER BY ...)` | `FIRST_VALUE(price) OVER(PARTITION BY category ORDER BY price)` |
| `LAST_VALUE()` | Последнее значение в окне | `LAST_VALUE(col) OVER(ORDER BY ...)` | `LAST_VALUE(price) OVER(PARTITION BY category ORDER BY price)` |
| **Условная логика** ||||
| `CASE` | Условное ветвление, как if/elif/else | `CASE WHEN усл THEN рез ... ELSE рез END` | `CASE WHEN salary>100000 THEN 'высокая' ELSE 'обычная' END` |
| `COALESCE()` | Первое не-NULL значение из списка | `COALESCE(expr1, expr2, ...)` | `COALESCE(fax, phone, 'нет контакта')` |
| `NULLIF()` | NULL, если два значения равны, иначе первое | `NULLIF(expr1, expr2)` | `NULLIF(units_in_stock, 0)` |
| **Поиск и связывание значений** ||||
| `IN()` | Проверка вхождения в список | `столбец IN (значения)` | `WHERE department IN ('IT', 'Продажи')` |
| `EXISTS()` | Проверяет, вернул ли подзапрос хоть одну строку | `WHERE EXISTS (подзапрос)` | `WHERE EXISTS (SELECT * FROM orders o WHERE o.customer_id = c.id)` |
| `BETWEEN` | Значение в диапазоне (включительно) | `столбец BETWEEN a AND b` | `WHERE salary BETWEEN 70000 AND 100000` |
| `LIKE` / `ILIKE` | Поиск по шаблону (ILIKE — регистронезависимо) | `столбец LIKE 'шаблон'` | `WHERE name LIKE 'Иван%'` |
| **Текстовые функции** ||||
| `CONCAT()` | Склеивает строки | `CONCAT(str1, str2, ...)` | `CONCAT(first_name, ' ', last_name)` |
| `\|\|` | Склеивает строки (PostgreSQL-оператор) | `str1 \|\| str2` | `'Post' \|\| 'greSQL'` |
| `LENGTH()` | Длина строки | `LENGTH(строка)` | `LENGTH(name)` |
| `LOWER()` / `UPPER()` | Нижний / верхний регистр | `LOWER(строка)` | `LOWER(email)` |
| `TRIM()` | Убирает пробелы/символы по краям | `TRIM(строка)` | `TRIM('  текст  ')` |
| `SUBSTRING()` | Извлекает часть строки | `SUBSTRING(строка FROM n FOR m)` | `SUBSTRING(name FROM 1 FOR 3)` |
| **Числовые функции** ||||
| `ROUND()` | Округление до N знаков | `ROUND(число, знаков)` | `ROUND(price, 2)` |
| `ABS()` | Модуль числа | `ABS(число)` | `ABS(-15)` |
| `FLOOR()` / `CEILING()` | Округление вниз / вверх до целого | `FLOOR(число)` | `FLOOR(4.7)` → 4 |
| **Функции дат** ||||
| `NOW()` | Текущая дата и время | `NOW()` | `SELECT NOW()` |
| `CURRENT_DATE` | Текущая дата (без времени) | `CURRENT_DATE` | `WHERE order_date = CURRENT_DATE` |
| `CURRENT_TIME` | Текущее время (без даты) | `CURRENT_TIME` | `SELECT CURRENT_TIME` |
| `EXTRACT()` | Достаёт часть даты (год, месяц, день, час и т.д.) | `EXTRACT(поле FROM дата)` | `EXTRACT(MONTH FROM order_date)` |
| `DATE_PART()` | То же самое, что EXTRACT, другой синтаксис | `DATE_PART('поле', дата)` | `DATE_PART('year', order_date)` |
| `DATE_TRUNC()` | Обрезает дату до нужной точности (день/месяц/год) | `DATE_TRUNC('поле', дата)` | `DATE_TRUNC('month', order_date)` — обрежет до первого числа месяца |
| `AGE()` | Разница между датой и текущим моментом (интервал) | `AGE(дата)` или `AGE(дата1, дата2)` | `AGE(hire_date)` → "2 years 3 mons" |
| `TO_CHAR()` | Дата → текст в нужном формате | `TO_CHAR(дата, формат)` | `TO_CHAR(order_date, 'DD.MM.YYYY')` |
| `TO_DATE()` | Текст → дата | `TO_DATE(текст, формат)` | `TO_DATE('05 Dec 2000', 'DD Mon YYYY')` |
| `TO_TIMESTAMP()` | Текст → дата со временем | `TO_TIMESTAMP(текст, формат)` | `TO_TIMESTAMP('05 Dec 2000 22:04', 'DD Mon YYYY HH24:MI')` |
| `MAKE_DATE()` | Собирает дату из отдельных чисел (год, месяц, день) | `MAKE_DATE(год, месяц, день)` | `MAKE_DATE(2026, 3, 15)` |
| `дата + INTERVAL` | Прибавить/отнять интервал времени к дате | `дата + INTERVAL 'n единица'` | `order_date + INTERVAL '7 days'` |
| `дата1 - дата2` | Разница между двумя датами в днях | `дата1 - дата2` | `NOW() - order_date` |
| **Функции дат (диалект MySQL)** ||||
| `DATEDIFF()` | Разница в днях между двумя датами | `DATEDIFF(дата1, дата2)` | `DATEDIFF('2026-05-09', '2026-05-01')` → 8 |
| `YEAR()` | Год из даты | `YEAR(дата)` | `YEAR('2026-04-12')` → 2026 |
| `MONTH()` | Номер месяца из даты | `MONTH(дата)` | `MONTH('2026-04-12')` → 4 |
| `MONTHNAME()` | Название месяца (на английском) | `MONTHNAME(дата)` | `MONTHNAME('2026-04-12')` → April |
| `DAY()` | День месяца из даты | `DAY(дата)` | `DAY('2026-04-12')` → 12 |

---

## Про оконные функции отдельно — синтаксис целиком

```sql
имя_функции(столбец) OVER (
    PARTITION BY столбец   -- на какие группы делить (необязательно)
    ORDER BY столбец       -- порядок внутри группы (нужен для ранжирующих и смещений)
)
```

**Главное отличие от GROUP BY:** строки не схлопываются, каждая остаётся видна,
рядом добавляется результат агрегата по её партиции.
