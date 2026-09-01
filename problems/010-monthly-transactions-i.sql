-- source: leetcode 1193 https://leetcode.com/problems/monthly-transactions-i/
-- problem: Monthly Transactions I (Medium) [Database]
-- pattern: conditional aggregation (several conditional aggregates in one output row)
-- date: 2026-08-31
-- minutes taken: 29 (2026-08-31), 0 hints
-- solved unaided (y/n): n -- 0 hints and no worked example, the closest to unaided today; but the missing alias and the dialect swap were both surfaced by a coach prompt to run the check, not self-initiated

-- Table: Transactions
--
-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | id            | int     |
-- | country       | varchar |
-- | state         | enum    |
-- | amount        | int     |
-- | trans_date    | date    |
-- +---------------+---------+
-- id is the primary key of this table.
-- The table has information about incoming transactions.
-- The state column is an enum of type ["approved", "declined"].
--
-- Write an SQL query to find for each month and country, the number of transactions and their total amount, the number of approved transactions and their total amount.
--
-- Return the result table in any order.
--
-- The query result format is in the following example.
--
-- Example 1:
--
-- Input:
-- Transactions table:
-- +------+---------+----------+--------+------------+
-- | id   | country | state    | amount | trans_date |
-- +------+---------+----------+--------+------------+
-- | 121  | US      | approved | 1000   | 2018-12-18 |
-- | 122  | US      | declined | 2000   | 2018-12-19 |
-- | 123  | US      | approved | 2000   | 2019-01-01 |
-- | 124  | DE      | approved | 2000   | 2019-01-07 |
-- +------+---------+----------+--------+------------+
-- Output:
-- +----------+---------+-------------+----------------+--------------------+-----------------------+
-- | month    | country | trans_count | approved_count | trans_total_amount | approved_total_amount |
-- +----------+---------+-------------+----------------+--------------------+-----------------------+
-- | 2018-12  | US      | 2           | 1              | 3000               | 1000                  |
-- | 2019-01  | US      | 1           | 1              | 2000               | 2000                  |
-- | 2019-01  | DE      | 1           | 1              | 2000               | 2000                  |
-- +----------+---------+-------------+----------------+--------------------+-----------------------+


-- BODY AS RUN IN DUCKDB (the bar). Uses strftime, which is DuckDB-only.
SELECT
    strftime(trans_date, '%Y-%m') AS month,
    country,
    COUNT(strftime(trans_date, '%Y-%m')) AS trans_count,
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM Transactions
GROUP BY month, country;

-- AS SUBMITTED TO LEETCODE (accepted). Identical except the date expression,
-- because DATE_FORMAT is MySQL-only and errors in DuckDB:
--   DATE_FORMAT(trans_date, '%Y-%m') AS month
--   COUNT(DATE_FORMAT(trans_date, '%Y-%m')) AS trans_count
--
-- First problem in this repo where no single text passes both oracles. The
-- month expression has no shared spelling between the two engines at this
-- format. A portable third option, verified in DuckDB on 2026-08-31 and valid
-- MySQL, if a single text is ever wanted:
--   SUBSTR(CAST(trans_date AS VARCHAR), 1, 7) AS month
--
-- Notes:
--   - The dialect split was caught BEFORE submitting, unprompted, in answer to
--     "is there anything in this query that is DuckDB-only". That is the card
--     from 197 working as intended rather than costing a rejected submit.
--   - Four attempts went into inventing a postfix conditional on an aggregate:
--     SUM(amount) IF state = 'approved', then WHEN in place of IF. No such
--     construct exists in any engine. The condition goes INSIDE the aggregate,
--     in a CASE, which was already working one column to the left.
--   - SUM(amount) shipped unaliased and printed as sum(amount). Caught by
--     comparing the stated output-column check against the actual header.
--     Third instance today of a known fix not reaching the line.
