# Путь в аналитику: SQL + Power BI

# SQL: от основ до продвинутого уровня
![Course Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![SQL](https://img.shields.io/badge/SQL-PostgreSQL%20%7C%20MySQL-blue)

**Итоговый уровень:** уверенная база для аналитических запросов — от простого SELECT
до оконных функций и объединения запросов. Репозиторий содержит структурированные
конспекты, шпаргалки и решённые практические задания по итогам курса.

---

## Чему научился / приобретённые компетенции

**Уверенно применяю на практике:**
- Аналитические запросы: построение `SELECT` с фильтрацией, группировкой
  (`GROUP BY`, `HAVING`), сортировкой и пагинацией (`LIMIT`/`OFFSET`)
- Работа с несколькими таблицами: все виды `JOIN` (`INNER`, `LEFT`/`RIGHT`, `FULL`,
  `CROSS`), включая соединение через связующие таблицы при отсутствии прямой связи
- Подзапросы и `CTE` (Common Table Expressions) для читаемых многошаговых запросов
- Оконные функции: `PARTITION BY`, ранжирующие (`ROW_NUMBER`, `RANK`, `DENSE_RANK`),
  агрегатные и смещающие (`LAG`, `LEAD`) — понимание отличия от `GROUP BY`
- Объединение запросов: `UNION`/`UNION ALL`, `INTERSECT`, `EXCEPT`
- Условная логика и безопасная обработка `NULL`: `CASE`, `COALESCE`, `NULLIF`
- Точное понимание порядка выполнения SQL-запроса (не путаю с порядком написания)

**Знаком с концепцией, применял в учебных задачах:**
- Операторы `ANY`/`ALL` для сравнения с результатом подзапроса
- Оконные фреймы (`ROWS`, `RANGE`, `GROUPS`) — общее понимание принципа
- Нормализация базы данных — понимание цели (устранение избыточности данных)
- DDL/DML операторы: `CREATE`, `ALTER`, `INSERT`, `UPDATE`, `DELETE`, ограничения
  (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`)

**Пройдено в курсе (теоретическое знакомство):**
- Представления (`VIEW`), пользовательские функции, триггеры
- Экспорт данных и создание дампов БД

---

## Стек и инструменты

| Категория | Инструменты / технологии |
|---|---|
| СУБД | PostgreSQL (основная), знакомство с диалектом MySQL |
| Клиенты | DBeaver, pgAdmin 4 |
| Управление версиями | Git, GitHub |

---

## Структура репозитория

```
sql-learning/
├── 01_basics/              # Введение, типы данных, первые SELECT, порядок выполнения
├── 02_joins-sets/          # Все типы JOIN, UNION, INTERSECT, EXCEPT
├── 03_functions-logic/     # Строковые/числовые/дата функции, CASE, CTE, подзапросы
├── 04_ddl-dml/             # CREATE, ALTER, INSERT, UPDATE, DELETE, CONSTRAINTS
├── 05_window-functions/    # Оконные функции: фреймы, ранжирование, смещение
└── docs/                   # Шпаргалки, схемы порядка выполнения, конспекты
power-bi-learning/
└── 01_etl-power-query/    # Подключение источников, преобразования, календарь, Group By
README.md
```

---

### SQL
- [Базовые SELECT-запросы](sql-learning/01_basics/)
- [JOIN и объединение таблиц](sql-learning/02_joins-sets/)
- [Функции и логика](sql-learning/03_functions-logic/)
- [DDL/DML](sql-learning/04_ddl-dml/)
- [Оконные функции](sql-learning/05_window-functions/)

**Шпаргалки:**
- [Схема БД Nordwind](sql-learning/docs/nordwind_schema.md)
- [Порядок выполнения запроса](sql-learning/docs/sql_cheatsheet.md)
- [Функции SQL: назначение, синтаксис, пример](sql-learning/docs/sql_functions_cheatsheet.md)
- [ABC-анализ через оконные функции (разбор из курса)](sql-learning/docs/abc_analysis_cheatsheet.md)
- [XYZ-анализ через коэффициент вариации (разбор из курса)](sql-learning/docs/xyz_analysis_cheatsheet.md)
- [Комбинированный ABC-XYZ анализ и VIEW (разбор из курса)](sql-learning/docs/abc_xyz_combined_cheatsheet.md)

---
# Microsoft Power BI, Power Query, DAX
![Course Status](https://img.shields.io/badge/Status-In%20Progress-blue)
![Power BI](https://img.shields.io/badge/Power%20BI-Power%20Query%20%7C%20DAX-yellow)

- [ETL-процессы: подключение источников, Power Query](power-bi-learning/01_etl-power-query/etl_power_query.md)

---

## О репозитории

Материалы курса ["SQL: от основ до продвинутого уровня"](https://stepik.org/course/181875/syllabus)
на Stepik, дополненные собственными шпаргалками и практикой на тестовых наборах данных.
Продвинутые темы (триггеры, представления, оконные фреймы) изучены на уровне курса
и вынесены отдельно как база для дальнейшего углубления — по мере появления практических
задач буду переносить их из раздела "пройдено в курсе" в раздел "уверенно применяю".
