# reference.md

Syntax, grammar, and environment mechanics. Everything here is material the drill
rules hand over free at any time: function names, operators, syntax, and how to
read an error. Look things up here instead of guessing — guessing at syntax
teaches nothing, and it has cost real attempt-minutes (`!= NULL` four times on
584, `content CHAR` on 1683).

**This file deliberately stops short.** It does not cover conditional aggregation,
the WHERE-vs-HAVING choice, CTEs vs subqueries, or the two-alias self-join. Those
are unattempted patterns with worked examples pending; writing them here would
hand over the rep. Pattern skeletons live in `patterns.md` and are not duplicated
here — one source of truth.

---

## 1. DuckDB, start to finish

```
duckdb drill.duckdb                  # open the drill database
.read problems/007-slug-setup.sql    # load a setup file
SHOW TABLES;                         # what's loaded
DESCRIBE Weather;                    # column names and types
SELECT * FROM Weather;               # look at the actual rows before writing anything
.quit
```

`get.ps1` prints a Python one-liner instead. Both work; the CLI above is better
while solving because you stay in the session.

Statements need a trailing `;`. Without one the CLI waits for more input and
looks frozen — it isn't, finish the statement or hit Ctrl-C.

`.mode box` (default), `.mode line` when a wide row wraps badly.

### Reading a DuckDB error

| Message | What it actually means |
|---|---|
| `Parser Error: syntax error at or near "X"` | Grammar. Look at the token *before* the one named. |
| `Binder Error: Referenced column "x" not found` | Typo, wrong case, or wrong table alias. `DESCRIBE` the table. |
| `Catalog Error: Table with name X does not exist` | Setup file never loaded, or loaded into a different db file. |
| `Conversion Error` | Type mismatch — usually a string where a DATE or number belongs. |
| `Binder Error: column must appear in the GROUP BY clause` | A selected column is neither grouped nor aggregated. |

An error naming a column is a *cheaper* signal than a wrong answer. Read it
before changing anything.

---

## 2. NULL

`IS NULL` and `IS NOT NULL` are the only tests. There is no other way.

```sql
WHERE referee_id IS NULL          -- correct
WHERE referee_id = NULL           -- always NULL, matches nothing, no error
WHERE referee_id != NULL          -- same, silently drops every row
```

Any comparison against NULL yields NULL, and a WHERE keeps only rows that are
true. NULL is not false — it is unknown — but the row is dropped either way.

| | |
|---|---|
| `COALESCE(a, b, c)` | first non-NULL argument |
| `NULLIF(a, b)` | NULL when `a = b`, else `a` |
| `a IS DISTINCT FROM b` | NULL-safe `!=` — true when one side is NULL |

**Absence is NULL, never a zero value.** A missing row and a row holding `0` are
different things.

---

## 3. Aliases and quoting

```sql
SELECT article_id AS id           -- AS is optional; write it anyway
FROM Views AS v                   -- table alias
ORDER BY id                       -- alias works here
```

Quoting is where 1148 went wrong:

| Written | Means |
|---|---|
| `id` | the column |
| `"id"` | the column, quoted as an identifier |
| `'id'` | **the three-character string** — `ORDER BY 'id'` sorts by a constant, so it sorts nothing |

Single quotes are always a string literal. Never use them for a column.

---

## 4. Clause order

Written order:

```sql
SELECT ... FROM ... WHERE ... GROUP BY ... HAVING ... ORDER BY ... LIMIT ...
```

Execution order:

```
FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> DISTINCT -> ORDER BY -> LIMIT
```

Consequences that matter:

- A SELECT alias is **not** usable in `WHERE` — SELECT hasn't run yet.
- A SELECT alias **is** usable in `ORDER BY` — SELECT already ran.
- `ORDER BY` sorts. `GROUP BY` collapses rows. They are not interchangeable, and
  reaching for `GROUP BY` to sort or dedupe is a recurring error of yours.
- To dedupe, `DISTINCT`. To sort, `ORDER BY`.

**Dialect trap:** DuckDB permits a SELECT alias in `WHERE` and `GROUP BY`. MySQL
does not. A query DuckDB accepts can therefore fail the LeetCode submit — that
is exactly the case the rules say becomes a pattern card.

---

## 5. Joins

```sql
FROM orders AS o
INNER JOIN customers AS c ON o.customer_id = c.customer_id
```

- Always state the type. Never a bare `JOIN`.
- `INNER JOIN` — only matching rows survive.
- `LEFT JOIN` — every row of the **FROM** table survives; unmatched right-side
  columns come back NULL.
- `RIGHT JOIN`, `FULL OUTER JOIN` — mirror and union of the above.
- `USING (customer_id)` when the key name is identical on both sides.
- Multiple conditions: `ON a.k = b.k AND a.d = b.d`.

Two independent knobs: **which table is in FROM** (which side is kept whole) and
**which type** (whether unmatched rows survive). Neither one decides the output
columns — the SELECT list does.

---

## 6. Aggregates

| | |
|---|---|
| `COUNT(*)` | rows, NULLs included |
| `COUNT(col)` | rows where `col` is not NULL |
| `COUNT(DISTINCT col)` | distinct non-NULL values |
| `SUM`, `AVG`, `MIN`, `MAX` | all skip NULLs |

`AVG` over zero rows is NULL, not 0.

Every column in SELECT must be either inside an aggregate or named in `GROUP BY`.

---

## 7. Numbers

| | |
|---|---|
| `ROUND(x, 2)` | round to 2 decimal places |
| `CAST(x AS DOUBLE)` or `x::DOUBLE` | DuckDB cast; `::` is not MySQL |
| `x / y` | DuckDB returns a float for int operands |
| `x // y` | DuckDB integer division (MySQL: `DIV`) |

---

## 8. Dates

| | DuckDB | MySQL / LeetCode |
|---|---|---|
| today | `CURRENT_DATE` | `CURDATE()` |
| format | `strftime(d, '%Y-%m')` | `DATE_FORMAT(d, '%Y-%m')` |
| difference | `date_diff('day', a, b)` | `DATEDIFF(a, b)` |
| shift | `d + INTERVAL 1 DAY` | `DATE_ADD(d, INTERVAL 1 DAY)` |
| shift back | `d - INTERVAL 1 DAY` | `DATE_SUB(d, INTERVAL 1 DAY)` |

Dates are not strings. Comparing a `DATE` column to `'2015-01-01'` works because
the literal gets cast; comparing it to a formatted string generally does not.

---

## 9. Before asking for a hint

Run this list first. Most of your logged errors are on it.

1. Did you `SELECT *` and actually look at the rows?
2. Did you `DESCRIBE` the table, or assume the column names?
3. Does the spec say "each" / "every" / "all"? That constrains which side is kept.
4. Does it say "did not" / "never" / "no"? Then absence is NULL, not `0`.
5. Are you using `GROUP BY` where you meant `ORDER BY` or `DISTINCT`?
6. Did you compare anything to `NULL` with `=` or `!=`?
7. Does the required output column name match the spec exactly?
8. Re-read the condition in the question word for word. 1757 was lost to reading
   `low_fats = 'Y'` as `'N'`.
