# Pattern cards

One card per pattern I have missed, written at the moment of the error, never batched
at the end of a session. A multi-error problem produces one card per distinct error.

Ladder: 1, 3, 7, 21 days, anchored to last_review. A miss puts the card back on the
1-day rung and increments lapses. A pass advances one rung and sets next_review to
last_review plus the new rung; a pass on the 21-day rung retires the card, and a
fresh error on a retired pattern brings it back at the 1-day rung.

lapses counts REVIEW misses only. The error that creates a card is lapse 0, so a
card can sit at 0 lapses and still have come from a real mistake. first_seen is set
once and never rewritten, and lapses is never reset. A card at 3+ lapses is a leech:
it gets rewritten inside the Sunday 3:00-3:30 deck slot, rewrite before retrieval
and capped at 10 minutes, into the smallest testable unit with a concrete failing
example from log.csv, rather than going back into the rotation.

A suspended card is out of the rotation until its rewrite lands. It is not due, it
does not lapse while suspended, and it re-enters at the 1-day rung on the day it is
rewritten. Suspension is normally the leech rule firing at 3+ lapses; it can also be
called early by decision, which is recorded in the row.

Mechanics ratified 2026-08-26 (Command Center). first_seen and lapses below were
reconstructed from git history, because the previous mechanics overwrote first_seen
on every miss and kept no lapse count.

| pattern | the tell in the question | skeleton query | first_seen | lapses | last_review | next_review |
| --- | --- | --- | --- | --- | --- | --- |
| NULL is not comparable | "not referred by any", "never ordered", "has no manager" — anything where the absence of a value should count as a match | `SELECT c FROM t WHERE c <> v OR c IS NULL` — the second branch is the whole point, a comparison alone silently drops NULL rows | 2026-08-18 | 2 | 2026-08-26 | suspended, rewrite Sun 2026-08-30 |
| Output shape is part of the spec | the example output shows a column name that does not exist in the source schema, or says "sorted by" / "each ... once" | `SELECT DISTINCT src AS out FROM t WHERE p ORDER BY out` — sorting by the alias works because ORDER BY runs after SELECT | 2026-08-18 | 3 | 2026-08-31 | suspended, rewrite Sun 2026-09-06 |
| Length of a string is a function call | "number of characters", "longer than N", "content exceeds" — a size test on a text column | `SELECT id FROM t WHERE CHAR_LENGTH(c) > n`. MySQL and Redshift: CHAR_LENGTH is characters, LENGTH is bytes in MySQL. LEN is SQL Server only and errors on LeetCode | 2026-08-18 | 2 | 2026-08-31 | 2026-09-01 |
| Logical clause order | any query where an alias, an aggregate filter, or a GROUP BY is involved — and any time I reach for GROUP BY to sort or dedupe | FROM then WHERE then GROUP BY then HAVING then SELECT then DISTINCT then ORDER BY then LIMIT. Alias unusable in WHERE, usable in ORDER BY. Aggregate filters go in HAVING, not WHERE | 2026-08-19 | 3 | 2026-08-31 | suspended, rewrite Sun 2026-09-06 |
| Join side and join type are two separate knobs | two tables, and the wording implies one side must be kept whole — "each sale", "every employee", "all customers", "report ... for each X" | `FROM kept_table LEFT JOIN other ON kept_table.k = other.k`. The table in FROM is the one whose rows all survive, so swapping FROM and JOIN changes the answer. LEFT vs INNER decides whether unmatched rows survive. Neither one decides columns — the SELECT list does | 2026-08-20 | 1 | 2026-08-31 | 2026-09-07 |
| Anti-join: rows with no match on the other side | "did not", "never", "with no ...", "visited but did not buy", "customers who never ordered" | `SELECT ... FROM kept LEFT JOIN other ON kept.k = other.k WHERE other.any_col IS NULL`. The LEFT JOIN NULL-fills the non-matches, then the WHERE keeps only those. Absence is NULL, never a zero value | 2026-08-24 | 3 | 2026-08-31 | suspended, rewrite Sun 2026-09-06 |
| Compare a row to another row of the same table | "higher than the previous day", "compared to yesterday", "than the row before", any comparison between two rows of one table | `SELECT a.id FROM t AS a INNER JOIN t AS b ON <how a relates to b> WHERE a.col > b.col`. Two aliases put both rows into one output row, which is the only thing WHERE can ever see. INNER drops the first row, correctly, since it has no predecessor | 2026-08-24 | 1 | 2026-08-26 | 2026-08-27 |
| Read the spec before writing (process card, not a query pattern) | every problem — 4 of 5 misses on d2 were misreads or invented syntax, not gaps in SQL. Includes boundary wording: "less than" is `<`, "at most" is `<=`, and the judge may have no test data on the boundary to catch it | before typing: name the source, the output columns, the filter, the sort, and whether duplicates are allowed. Check every comparison against the exact wording. Unknown syntax gets looked up, never guessed | 2026-08-18 | 0 | 2026-08-26 | 2026-09-02 |
| JOIN takes a table, ON takes a condition | any parser error at or near `JOIN`, `ON`, or `AND`; or reaching for a join and finding table names and column names have swapped places | `FROM t AS a INNER JOIN t AS b ON a.k = b.k`. Four rules: the alias attaches to the TABLE in FROM/JOIN, never to a column in SELECT. `JOIN` is followed by one table name, never a column and never a list joined by AND. `ON` takes a boolean condition containing a comparison operator, never a bare column name. Once a table is aliased, every column reference is `alias.column`. Concrete failure 2026-08-27 on 197: `SELECT id as id, id as id1 FROM Weather INNER JOIN id AND id1 ON temperature WHERE id > id1` | 2026-08-27 | 0 | 2026-08-27 | 2026-08-28 |
| Date minus a bare integer is DuckDB-only | any date offset — "yesterday", "the previous day", "the day before", "within N days" — and generally: any query DuckDB accepts that LeetCode then rejects on Submit | `ON b.d = a.d - INTERVAL 1 DAY` is portable and runs in both. `a.d - 1` is real date arithmetic in DuckDB but silent integer arithmetic on YYYYMMDD in MySQL: `2015-01-01 - 1` = `20150100`, not a date. Passes LeetCode Run on the 4-row sample (2015-01-01..04, no month boundary crossed) and fails Submit on hidden tests that cross one. Run tests the sample; Submit tests the hidden set; only Submit is the oracle. Concrete failure 2026-08-27 on 197 | 2026-08-27 | 0 | 2026-08-27 | 2026-08-28 |
| Do not silence a GROUP BY error by widening the GROUP BY | the binder error `column X must appear in the GROUP BY clause or be used in an aggregate function`, and the temptation to paste X into GROUP BY to make it go away | The error means SELECT asked a bucket a question it cannot answer. Two real fixes: wrap X in an aggregate, or stop selecting it. Adding X to GROUP BY is a third path that silences the error by building SMALLER buckets — it changes the grain of the answer and returns a wrong result with no error at all, which is worse than the error. Before adding a column to GROUP BY, say out loud what one output row now means. Concrete failure 2026-08-27 on 1211: `GROUP BY query_name, rating` returned 5 rows, Cat three times, where the spec wants one row per query_name | 2026-08-27 | 1 | 2026-08-31 | 2026-09-01 |
