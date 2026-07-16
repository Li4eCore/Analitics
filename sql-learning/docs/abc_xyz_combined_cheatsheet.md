# Комбинированный ABC-XYZ анализ и представления (VIEW)

> Разбор материала курса ["ABC-XYZ анализ в SQL"](https://stepik.org/course/197644/syllabus)
> на Stepik — конспект логики, не самостоятельно решённая задача.
> Дополняет [ABC-анализ](abc_analysis_cheatsheet.md) и [XYZ-анализ](xyz_analysis_cheatsheet.md).

Идея: ABC отвечает на вопрос "насколько товар важен" (по объёму или выручке),
XYZ отвечает на вопрос "насколько предсказуем спрос на товар". По отдельности
каждый анализ даёт только половину картины — вместе они образуют матрицу
из 9 комбинаций, которая куда полезнее для реальных решений по ассортименту.

---

## Зачем оборачивать запрос в VIEW

`VIEW` — это "сохранённый запрос", к которому можно обращаться как к обычной
таблице (`SELECT * FROM pizza_abc_analysis`), не переписывая логику каждый раз.

Три причины, почему это уместно именно здесь:
1. **Согласованность** — все, кто обращается к `pizza_abc_analysis`, видят
   одинаковый результат, посчитанный по одной и той же логике
2. **Безопасность** — можно дать доступ только к представлению, скрыв
   исходные таблицы с сырыми данными
3. **Упрощение** — сложная логика (CTE + оконные функции) спрятана внутри
   VIEW, а снаружи её вызывают одной простой строкой

---

## VIEW для ABC-анализа

```sql
CREATE OR REPLACE VIEW pizza_abc_analysis AS
WITH pizza_sales_by_name AS (
    SELECT
        name AS pizza_name,
        SUM(quantity) AS total_units_sold,
        SUM(revenue) AS total_revenue
    FROM pizza_sales
    WHERE year = 2015
    GROUP BY name
)
SELECT
    pizza_name,
    total_units_sold,
    total_revenue,
    CASE
        WHEN SUM(total_units_sold) OVER (
            ORDER BY total_units_sold DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(total_units_sold) OVER () <= 0.8 THEN 'A'
        WHEN SUM(total_units_sold) OVER (
            ORDER BY total_units_sold DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(total_units_sold) OVER () <= 0.95 THEN 'B'
        ELSE 'C'
    END AS abc_category_by_units,
    CASE
        WHEN SUM(total_revenue) OVER (
            ORDER BY total_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(total_revenue) OVER () <= 0.8 THEN 'A'
        WHEN SUM(total_revenue) OVER (
            ORDER BY total_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(total_revenue) OVER () <= 0.95 THEN 'B'
        ELSE 'C'
    END AS abc_category_by_revenue
FROM pizza_sales_by_name
ORDER BY abc_category_by_units, abc_category_by_revenue, total_revenue DESC;
```

Отличие от версии без явного фрейма (см. файл про ABC-анализ): здесь накопительная
сумма считается с явным `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` —
то же самое поведение, что и по умолчанию у `SUM() OVER (ORDER BY ...)`, но
записано в явном виде для полной прозрачности расчёта.

**Просмотр:** `SELECT * FROM pizza_abc_analysis`

---

## VIEW для XYZ-анализа

```sql
CREATE OR REPLACE VIEW pizza_xyz_analysis AS
WITH sales_by_month AS (
    SELECT
        name AS pizza_name,
        TO_DATE(month_year, 'DD.MM.YYYY') AS sale_month,
        SUM(quantity) AS monthly_quantity
    FROM pizza_sales
    WHERE year = 2015
    GROUP BY name, TO_DATE(month_year, 'DD.MM.YYYY')
),
variation_calculation AS (
    SELECT
        pizza_name,
        STDDEV_POP(monthly_quantity) AS standard_deviation,
        AVG(monthly_quantity) AS average_quantity,
        ROUND(STDDEV_POP(monthly_quantity) / AVG(monthly_quantity), 5) AS variation_coefficient
    FROM sales_by_month
    GROUP BY pizza_name
)
SELECT
    pizza_name,
    variation_coefficient,
    CASE
        WHEN variation_coefficient <= 0.1 THEN 'X'
        WHEN variation_coefficient <= 0.12 THEN 'Y'
        ELSE 'Z'
    END AS xyz_category
FROM variation_calculation
ORDER BY xyz_category, pizza_name;
```

**Просмотр:** `SELECT * FROM pizza_xyz_analysis`

---

## Объединение через VIEW: JOIN + конкатенация строк (`||`)

```sql
SELECT
    a.pizza_name,
    a.total_units_sold,
    a.total_revenue,
    a.abc_category_by_units || x.xyz_category AS abc_by_units_xyz,
    a.abc_category_by_revenue || x.xyz_category AS abc_by_revenue_xyz,
    a.abc_category_by_units || a.abc_category_by_revenue || x.xyz_category AS abc_units_revenue_xyz
FROM pizza_abc_analysis a
JOIN pizza_xyz_analysis x
    ON a.pizza_name = x.pizza_name
ORDER BY abc_units_revenue_xyz, total_revenue DESC;
```

`||` — оператор конкатенации строк (склейка). `'A' || 'X'` даёт `'AX'` —
так из двух однобуквенных категорий собирается итоговый код товара.

> **Важный нюанс из разбора:** в идеале JOIN таблиц стоит делать по уникальному
> идентификатору (`pizza_id`), а не по названию (`pizza_name`) — совпадающие
> названия у разных товаров привели бы к неверным результатам. Здесь JOIN
> по имени сделан вынужденно, так как в исходных данных не было отдельного id.

---

## Тот же результат одним запросом, без VIEW

Если не создавать постоянные представления, всю логику можно собрать
в один запрос через последовательность CTE:

```sql
WITH pizza_sales_by_name AS (
    SELECT name AS pizza_name, SUM(quantity) AS total_units_sold, SUM(revenue) AS total_revenue
    FROM pizza_sales
    WHERE year = 2015
    GROUP BY name
),
abc_calculated AS (
    SELECT
        pizza_name, total_units_sold, total_revenue,
        CASE
            WHEN SUM(total_units_sold) OVER (ORDER BY total_units_sold DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(total_units_sold) OVER () <= 0.8 THEN 'A'
            WHEN SUM(total_units_sold) OVER (ORDER BY total_units_sold DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(total_units_sold) OVER () <= 0.95 THEN 'B'
            ELSE 'C'
        END AS abc_category_by_units,
        CASE
            WHEN SUM(total_revenue) OVER (ORDER BY total_revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(total_revenue) OVER () <= 0.8 THEN 'A'
            WHEN SUM(total_revenue) OVER (ORDER BY total_revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(total_revenue) OVER () <= 0.95 THEN 'B'
            ELSE 'C'
        END AS abc_category_by_revenue
    FROM pizza_sales_by_name
),
monthly_sales_data AS (
    SELECT name AS pizza_name, TO_DATE(month_year, 'DD.MM.YYYY') AS sale_month, SUM(quantity) AS monthly_quantity
    FROM pizza_sales
    WHERE year = 2015
    GROUP BY name, TO_DATE(month_year, 'DD.MM.YYYY')
),
variation_calculation AS (
    SELECT
        pizza_name,
        STDDEV_POP(monthly_quantity) AS standard_deviation,
        AVG(monthly_quantity) AS average_quantity,
        ROUND(STDDEV_POP(monthly_quantity) / AVG(monthly_quantity), 5) AS variation_coefficient
    FROM monthly_sales_data
    GROUP BY pizza_name
),
xyz_category AS (
    SELECT
        pizza_name, variation_coefficient,
        CASE
            WHEN variation_coefficient <= 0.1 THEN 'X'
            WHEN variation_coefficient <= 0.12 THEN 'Y'
            ELSE 'Z'
        END AS xyz_category
    FROM variation_calculation
)
SELECT
    a.pizza_name,
    a.total_units_sold,
    a.total_revenue,
    a.abc_category_by_units || x.xyz_category AS abc_by_units_xyz,
    a.abc_category_by_revenue || x.xyz_category AS abc_by_revenue_xyz,
    a.abc_category_by_units || a.abc_category_by_revenue || x.xyz_category AS abc_units_revenue_xyz
FROM abc_calculated a
JOIN xyz_category x
    ON a.pizza_name = x.pizza_name
ORDER BY abc_units_revenue_xyz, total_revenue DESC;
```

**Структура из пяти CTE, по порядку:**
1. `pizza_sales_by_name` — агрегация продаж по товару
2. `abc_calculated` — расчёт ABC-категорий по количеству и выручке
3. `monthly_sales_data` — агрегация продаж по месяцам (нужна для XYZ)
4. `variation_calculation` — расчёт коэффициента вариации
5. `xyz_category` — классификация по XYZ на основе п.4

---

## Матрица интерпретации комбинированных категорий

**По количеству и стабильности (`abc_by_units_xyz`):**

| Код | Значение |
|---|---|
| AX | лидеры продаж со стабильным спросом |
| AY | лидеры продаж с переменным спросом |
| AZ | лидеры продаж с нестабильным спросом |
| BX | средние продажи со стабильным спросом |
| BY | средние продажи с переменным спросом |
| BZ | средние продажи с нестабильным спросом |
| CX | низкие продажи со стабильным спросом |
| CY | низкие продажи с переменным спросом |
| CZ | низкие продажи с нестабильным спросом |

**По выручке и стабильности (`abc_by_revenue_xyz`)** — та же логика,
но "продажи" заменяются на "доходность": AX = высокодоходные и стабильные,
CZ = низкая доходность и нестабильный спрос, и так далее по аналогии.

**Примеры трёхбуквенных комбинаций (количество + выручка + стабильность):**

| Код | Интерпретация |
|---|---|
| AAX | идеальный товар: много продаж, много выручки, стабильный спрос |
| ACZ | проблемный: много продаж, мало выручки, нестабильный спрос |
| CAY | нишевый: мало продаж, много выручки, переменный спрос |
| CCZ | кандидат на исключение: мало продаж, мало выручки, нестабильно |

---

## Как это использовать на практике (по выводам из разбора)

- **AAX-категория** — ядро ассортимента, туда стоит вкладывать основное
  внимание: стабильные поставки, оптимизация процессов
- **Товары с высоким CV (нестабильные, Z)** даже при хороших продажах
  требуют отдельного управления запасами — гибкие поставки, регулярный мониторинг
- **CCZ-категория** — кандидаты на пересмотр: низкие продажи, низкая
  доходность и непредсказуемый спрос одновременно — стоит решать, оставлять
  ли позицию в ассортименте вообще
