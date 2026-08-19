# Pattern cards

One card per pattern I have missed, written the day I miss it and reviewed 1, 3, 7, and
21 days after first_seen.

| pattern | the tell in the question | skeleton query | first_seen | last_reviewed | next_review |
| --- | --- | --- | --- | --- | --- |
| NULL is not comparable | "not referred by any", "never ordered", "has no manager" — anything where the absence of a value should count as a match | `SELECT c FROM t WHERE c <> v OR c IS NULL` | 2026-08-18 | | 2026-08-19 |
| Output shape is part of the spec | the example output shows a column name that does not exist in the source schema, or says "sorted by" / "each ... once" | `SELECT DISTINCT src AS out FROM t WHERE p ORDER BY out` | 2026-08-18 | | 2026-08-19 |
| Length of a string is a function call | "number of characters", "longer than N", "content exceeds" — a size test on a text column | `SELECT id FROM t WHERE CHAR_LENGTH(c) > n` | 2026-08-18 | | 2026-08-19 |
| Read the spec before writing (process card, not a query pattern) | every problem — 4 of 5 misses tonight were misreads or invented syntax, not gaps in SQL | before typing: name the output columns, the filter, the sort, and whether duplicates are allowed. Unknown syntax gets looked up, never guessed. | 2026-08-18 | | 2026-08-19 |
