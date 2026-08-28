# reference.md

Syntax, grammar, and environment mechanics. Everything here is material the drill
rules hand over free at any time: function names, operators, syntax, and how to
read an error. Look things up here instead of guessing — guessing at syntax
teaches nothing, and it has cost real attempt-minutes (`!= NULL` four times on
584, `content CHAR` on 1683).

**Syntax is not a pattern, and this file carries all the syntax.** Policy amended
2026-08-27 after the 1211 session, where `CASE WHEN` was absent from this file
because conditional aggregation was an unattempted *pattern* — and roughly 50
minutes went into trying to invent, from nothing, a keyword that was never
introduced. The old policy contradicted `CLAUDE.md`, which hands over "function
names, operators, syntax" free at any time. The line is:

- **Syntax** — that a keyword exists, what it is called, how it is punctuated,
  what it evaluates to. Free. It lives here, including for patterns not yet
  attempted. Section 11 is the full Block 1 inventory.
- **Pattern** — which construct to reach for, what to group by, how the pieces
  assemble into an answer. Withheld. That is the rep, and the skeletons live in
  `patterns.md` — one source of truth, not duplicated here.

Knowing `CASE WHEN` exists does not solve a conditional aggregation problem. It
lets you start one.

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

`get.ps1` prints a Python one-liner instead. Use the CLI. The two loaders are not
interchangeable, because DuckDB takes an **exclusive lock** on `drill.duckdb`:
only one process may hold the file open. With a CLI session running, the Python
one-liner fails with `IO Error: ... being used by another process` and names the
PID holding it. Load with `.read` from inside the session you already have open.

Two prompts, two languages. Confusing them costs minutes:

| prompt | what it takes |
|---|---|
| `D` | SQL statements and dot-commands (`.read`, `.quit`, `.mode`) |
| `PS C:\...>` | PowerShell (`cd`, `duckdb`, `py get.py <slug>`) |

`.\get.ps1 <slug>` at a `D` prompt gives `Unrecognized command`. It is a shell
script, not a DuckDB command.

If `.\get.ps1` is blocked with `running scripts is disabled on this system`, that
is the PowerShell execution policy. Either skip the wrapper — `py get.py <slug>`
is what it calls anyway — or fix it once with
`Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`.

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

**Dialect trap, verified 2026-08-27:** DuckDB accepts a SELECT alias in both
`WHERE` and `GROUP BY`. MySQL accepts it in `GROUP BY`, `HAVING`, and `ORDER BY`,
but **not** in `WHERE`. So `WHERE` is the one that can pass DuckDB and fail the
LeetCode submit — exactly the case the rules say becomes a pattern card.

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

`d - 1` is a trap. DuckDB reads it as date arithmetic and gives you the previous
day. MySQL coerces the date to the integer `YYYYMMDD` and subtracts one, so
`2015-01-01 - 1` becomes `20150100`, which is not a date. It survives any test
whose dates sit mid-month and breaks the moment one crosses a month or year
boundary — LeetCode's Run passes and its Submit fails. Write
`d - INTERVAL 1 DAY`; it is correct in both engines.

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

---

## 10. DuckDB-only sugar — do not use it

All four are confirmed working in DuckDB 1.5.5 and none exist in MySQL. They are
the only real way this setup could teach you a bad habit, so treat them as
off-limits and write the portable form instead.

| DuckDB-only | Write this instead |
|---|---|
| `GROUP BY ALL` | list the grouping columns explicitly |
| `SELECT * EXCLUDE (col)` | name the columns you want |
| `QUALIFY <window predicate>` | wrap in a CTE and filter in the outer `WHERE` |
| alias in `WHERE` | repeat the expression, or wrap in a CTE |
| trailing comma before `FROM` | drop it — DuckDB allows `a, b, FROM t`, MySQL rejects it |

Two more that work in DuckDB but are not portable to MySQL:

- `x::DOUBLE` — use `CAST(x AS DOUBLE)`, which is valid everywhere.
- `'a' || 'b'` — valid in DuckDB, Postgres, and Snowflake, but in MySQL `||`
  means OR by default. Use `CONCAT(a, b)`, which is valid in both.

`LENGTH` and `CHAR_LENGTH` both return characters in DuckDB. In MySQL `LENGTH`
returns **bytes** and `CHAR_LENGTH` returns characters. Prefer `CHAR_LENGTH`.

Everything else in sections 2 through 7 is ANSI SQL and behaves the same in
MySQL, Postgres, Redshift, Snowflake, and BigQuery. The portable-by-default rule
costs nothing here and means the LeetCode submit stops being a coin flip.

---

## 11. Block 1 syntax inventory

Every keyword and operator you will meet in the rest of Block 1. Grammar only:
what it is called, how it is punctuated, what it evaluates to. Nothing here says
which one to reach for.

### Booleans

A comparison — `rating < 3`, `a = b`, `x IS NULL` — evaluates to a BOOLEAN per
row: `true` or `false`. A boolean is **not** a number.

- You cannot divide by it. DuckDB: `No function matches ... '/(BOOLEAN, BIGINT)'`.
- `COUNT(x < 3)` counts **every** row. `COUNT` counts non-NULL values, and
  `false` is a perfectly good non-NULL value.
- `COUNT(DISTINCT x < 3)` can only ever return 1 or 2, for any data of any size.
- A bare comparison is a per-row value, so it cannot survive `GROUP BY` any more
  than a bare column can.
- `SUM(x < 3)` **does** work, in DuckDB and MySQL only: both add a boolean as 1
  for true and 0 for false, which is the engine writing the `CASE` for you.
  Postgres, SQL Server, and Snowflake reject it with a type error. Portable form
  is `SUM(CASE WHEN x < 3 THEN 1 ELSE 0 END)`. LeetCode is MySQL, so the short
  form passes there; write the portable one anywhere the engine is unknown.
- `COUNT(col)` as a denominator silently shrinks if `col` has NULLs. A percentage
  of all rows wants `COUNT(*)`.

### CASE

```sql
CASE WHEN <condition> THEN <value>
     WHEN <condition> THEN <value>
     ELSE <value>
END
```

- Evaluates to **one value per row**. It goes anywhere a value goes: a `SELECT`
  list, inside a function, inside an aggregate, in `ORDER BY`.
- `END` is required. Forgetting it is a parser error at the next keyword.
- `ELSE` is optional; without it, non-matching rows evaluate to NULL.
- Simple form, for equality against one expression:
  `CASE <expr> WHEN <val> THEN <value> ELSE <value> END`.
- Portable to MySQL, Postgres, Redshift, Snowflake, BigQuery.

### HAVING

```sql
GROUP BY col
HAVING <condition>
```

- Takes a **condition**, not a value — it needs a comparison operator in it. Same
  rule as `WHERE` and `ON`. `HAVING COUNT(x)` alone is not a condition.
- Runs after `GROUP BY`, so aggregates are available to it. `WHERE` runs before,
  so they are not. See section 4.

### CTEs

```sql
WITH daily_orders AS (
    SELECT ...
),
flagged_orders AS (
    SELECT ... FROM daily_orders
)
SELECT ...
FROM flagged_orders
```

- `WITH` once, at the top. Comma between CTEs. **No comma** before the final
  `SELECT`.
- Each CTE is named and referred to afterwards exactly like a table.
- MySQL 8.0+, DuckDB, Postgres. Not MySQL 5.7.

### Subqueries

| form | grammar |
|---|---|
| scalar | `WHERE x = (SELECT MAX(y) FROM t)` |
| list | `WHERE x IN (SELECT y FROM t)` |
| existence | `WHERE EXISTS (SELECT 1 FROM t WHERE t.k = o.k)` |
| derived table | `FROM (SELECT ...) AS alias` |

The alias on a derived table is **required** in MySQL. DuckDB will let you omit
it, which is a submit-time failure waiting to happen.

### Filtering operators

| | |
|---|---|
| `IN (a, b, c)` / `NOT IN (...)` | membership in a list |
| `BETWEEN a AND b` | inclusive on **both** ends |
| `LIKE 'A%'` | `%` matches any run of characters, `_` matches exactly one |
| `IS NULL` / `IS NOT NULL` | the only NULL tests; see section 2 |
| `AND`, `OR`, `NOT` | parenthesise when mixing `AND` and `OR` |

`NOT IN` against a list containing NULL returns **no rows at all**. That is the
NULL trap in section 2 wearing a different hat.

### Self-join aliasing

Grammar is in section 5: the alias attaches to the table in `FROM` and `JOIN`,
never to a column in `SELECT`, and one table may appear twice under two aliases.
