# ABC-анализ через оконные функции

Классическая бизнес-задача: разделить товары на группы A/B/C по вкладу
в общий результат (обычно 80% → A, следующие 15% → B, оставшиеся 5% → C).
Часто встречается как тестовое задание на позициях аналитика.

---

## Логика в двух шагах

**Шаг 1 — посчитать долю с накоплением (cumulative share).**

```sql
SUM(amount) OVER (ORDER BY amount DESC) / SUM(amount) OVER ()
```

Разберём по частям:
- `SUM(amount) OVER (ORDER BY amount DESC)` — **накопительная сумма**: для каждой
  строки складывает её значение и все значения строк "выше" по сортировке
  (это и есть "бегущий итог", running total)
- `SUM(amount) OVER ()` — **общая сумма по всей таблице**, без PARTITION и ORDER BY,
  окно охватывает вообще всё
- Деление первого на второе даёт **накопленную долю от общего итога**,
  нарастающую от самого крупного значения к самому мелкому

**Шаг 2 — раскидать по группам через CASE.**

```sql
CASE
    WHEN <накопленная_доля> <= 0.8 THEN 'A'
    WHEN <накопленная_доля> <= 0.95 THEN 'B'
    ELSE 'C'
END
```

Товары, которые вместе дают первые 80% продаж — группа A (самые важные),
следующие 15% (до 95% накопленных) — группа B, оставшиеся 5% — группа C.

---

## Полный запрос (двумерный ABC-анализ: по количеству и по сумме одновременно)

```sql
WITH sales AS (
    SELECT
        p.product_name,
        SUM(od.quantity) AS amount,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))) AS revenue
    FROM order_details AS od
    JOIN products AS p
        ON od.product_id = p.product_id
    GROUP BY p.product_name
)
SELECT
    product_name,
    CASE
        WHEN SUM(amount) OVER (ORDER BY amount DESC) / SUM(amount) OVER () <= 0.8 THEN 'A'
        WHEN SUM(amount) OVER (ORDER BY amount DESC) / SUM(amount) OVER () <= 0.95 THEN 'B'
        ELSE 'C'
    END AS abc_amount,
    CASE
        WHEN SUM(revenue) OVER (ORDER BY revenue DESC) / SUM(revenue) OVER () <= 0.8 THEN 'A'
        WHEN SUM(revenue) OVER (ORDER BY revenue DESC) / SUM(revenue) OVER () <= 0.95 THEN 'B'
        ELSE 'C'
    END AS abc_revenue
FROM sales;
```

**Почему именно так, по шагам:**
1. **CTE `sales`** — сначала сворачиваем детали заказов до одной строки на товар:
   сколько единиц продано (`amount`) и сколько денег принесло с учётом скидки (`revenue`).
   `revenue` считаем через `unit_price * quantity * (1 - discount)` — то есть скидка
   как доля (0.1 = 10%), а не как фиксированная сумма.
2. **Два независимых CASE** — один считает группу по количеству, второй — по выручке.
   Это и есть "двумерный" анализ: товар может быть, например, "A по количеству"
   но "C по выручке" (продаётся часто, но дёшево) — само по себе ценный инсайт.
3. Оконные функции не привязаны к `GROUP BY` — они считаются **после** того, как
   CTE уже свернул детали в товары, поэтому здесь `PARTITION BY` не нужен вообще,
   окно работает на весь результат сразу.

---

## Частая ошибка при повторении паттерна

Если использовать `SUM(amount) OVER (ORDER BY amount DESC)` без **дополнительного
уточнения tie-breaker** (например, по названию товара при равных `amount`) —
порядок накопления при одинаковых значениях может быть неоднозначным между
запусками в некоторых СУБД. Для строгой воспроизводимости лучше:
```sql
SUM(amount) OVER (ORDER BY amount DESC, product_name)
```
