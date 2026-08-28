-- source: leetcode 197 https://leetcode.com/problems/rising-temperature/
-- problem: Rising Temperature (Easy) [Database]
-- pattern: self-join on consecutive dates (row-to-row comparison within one table)
-- date: 2026-08-24
-- minutes taken: 35 first attempt 2026-08-24 (shown), 14 re-derivation 2026-08-27
-- solved unaided (y/n): n -- worked example granted, and a 4-of-5-line frame given

-- Table: Weather
--
-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | id            | int     |
-- | recordDate    | date    |
-- | temperature   | int     |
-- +---------------+---------+
-- id is the column with unique values for this table.
-- There are no different rows with the same recordDate.
-- This table contains information about the temperature on a certain day.
--
-- Write a solution to find all dates' id with higher temperatures compared to its previous dates (yesterday).
--
-- Return the result table in any order.
--
-- The result format is in the following example.
--
-- Example 1:
--
-- Input:
-- Weather table:
-- +----+------------+-------------+
-- | id | recordDate | temperature |
-- +----+------------+-------------+
-- | 1  | 2015-01-01 | 10          |
-- | 2  | 2015-01-02 | 25          |
-- | 3  | 2015-01-03 | 20          |
-- | 4  | 2015-01-04 | 30          |
-- +----+------------+-------------+
-- Output:
-- +----+
-- | id |
-- +----+
-- | 2  |
-- | 4  |
-- +----+
-- Explanation:
-- In 2015-01-02, the temperature was higher than the previous day (10 -> 25).
-- In 2015-01-04, the temperature was higher than the previous day (20 -> 30).

SELECT a.id
FROM Weather AS a
INNER JOIN Weather AS b
    ON b.recordDate = a.recordDate - INTERVAL 1 DAY
WHERE a.temperature > b.temperature;

-- DuckDB accepted `a.recordDate - 1`; LeetCode Submit rejected it. MySQL coerces
-- the date to the integer YYYYMMDD, so 2015-01-01 - 1 is 20150100, not a date.
-- INTERVAL 1 DAY is correct in both engines. See patterns.md and reference.md section 8.
