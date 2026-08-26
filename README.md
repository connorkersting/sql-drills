# sql-drills

Daily SQL drills for Amazon BIE and analytics data science interviews, fall 2026.

A session is one problem at a time: 15 minutes unaided, no lookups and no AI. Hints only
come after the timer, a full solution only after I've pasted my own attempt, and anything
I miss gets a pattern card before I move on. One commit per problem.

The problem is solved in DuckDB, not in LeetCode's editor. LeetCode supplies the problem
statement; it does not run the query. Save the query body, log the row, then commit, all
before the next problem starts. See CLAUDE.md for the full per-problem loop.

Every attempt is a row in log.csv. Pattern cards and their review dates are in patterns.md.
Problem files live in problems/, each one started from 000-template.sql.

Run `.\get.ps1 <leetcode-slug>` to pull a problem into problems/ as a numbered drill file
plus a setup file of sample rows, then load that into DuckDB with the command it prints.
