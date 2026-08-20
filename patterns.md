# Pattern cards

One card per pattern I have missed, written the day I miss it and reviewed 1, 3, 7, and
21 days after first_seen. A card missed during review gets first_seen reset, which puts
it back at the start of the ladder.

| pattern | the tell in the question | skeleton query | first_seen | last_reviewed | next_review |
| --- | --- | --- | --- | --- | --- |
| NULL is not comparable | "not referred by any", "never ordered", "has no manager" — anything where the absence of a value should count as a match | `SELECT c FROM t WHERE c <> v OR c IS NULL` — the second branch is the whole point, a comparison alone silently drops NULL rows | 2026-08-19 | 2026-08-19 | 2026-08-20 |
| Output shape is part of the spec | the example output shows a column name that does not exist in the source schema, or says "sorted by" / "each ... once" | `SELECT DISTINCT src AS out FROM t WHERE p ORDER BY out` — sorting by the alias works because ORDER BY runs after SELECT | 2026-08-18 | 2026-08-19 | 2026-08-21 |
| Length of a string is a function call | "number of characters", "longer than N", "content exceeds" — a size test on a text column | `SELECT id FROM t WHERE CHAR_LENGTH(c) > n`. MySQL and Redshift: CHAR_LENGTH is characters, LENGTH is bytes in MySQL. LEN is SQL Server only and errors on LeetCode | 2026-08-19 | 2026-08-19 | 2026-08-20 |
| Logical clause order | any query where an alias, an aggregate filter, or a GROUP BY is involved — and any time I reach for GROUP BY to sort or dedupe | FROM then WHERE then GROUP BY then HAVING then SELECT then DISTINCT then ORDER BY then LIMIT. Alias unusable in WHERE, usable in ORDER BY. Aggregate filters go in HAVING, not WHERE | 2026-08-19 | | 2026-08-20 |
| Read the spec before writing (process card, not a query pattern) | every problem — 4 of 5 misses on d2 were misreads or invented syntax, not gaps in SQL | before typing: name the source, the output columns, the filter, the sort, and whether duplicates are allowed. Unknown syntax gets looked up, never guessed | 2026-08-18 | 2026-08-19 | 2026-08-21 |
