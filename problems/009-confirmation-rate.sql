-- source: leetcode 1934 https://leetcode.com/problems/confirmation-rate/
-- problem: Confirmation Rate (Medium) [Database]
-- pattern: conditional aggregation (CASE WHEN inside an aggregate, per group)
-- date: 2026-08-31
-- minutes taken: 41 (2026-08-31), 1 hint
-- solved unaided (y/n): n -- 1 hint; the join direction was regressed and recovered

-- Table: Signups
--
-- +----------------+----------+
-- | Column Name    | Type     |
-- +----------------+----------+
-- | user_id        | int      |
-- | time_stamp     | datetime |
-- +----------------+----------+
-- user_id is the column of unique values for this table.
-- Each row contains information about the signup time for the user with ID user_id.
--
-- Table: Confirmations
--
-- +----------------+----------+
-- | Column Name    | Type     |
-- +----------------+----------+
-- | user_id        | int      |
-- | time_stamp     | datetime |
-- | action         | ENUM     |
-- +----------------+----------+
-- (user_id, time_stamp) is the primary key (combination of columns with unique values) for this table.
-- user_id is a foreign key (reference column) to the Signups table.
-- action is an ENUM (category) of the type ('confirmed', 'timeout')
-- Each row of this table indicates that the user with ID user_id requested a confirmation message at time_stamp and that confirmation message was either confirmed ('confirmed') or expired without confirming ('timeout').
--
-- The confirmation rate of a user is the number of 'confirmed' messages divided by the total number of requested confirmation messages. The confirmation rate of a user that did not request any confirmation messages is 0. Round the confirmation rate to two decimal places.
--
-- Write a solution to find the confirmation rate of each user.
--
-- Return the result table in any order.
--
-- The result format is in the following example.
--
-- Example 1:
--
-- Input:
-- Signups table:
-- +---------+---------------------+
-- | user_id | time_stamp          |
-- +---------+---------------------+
-- | 3       | 2020-03-21 10:16:13 |
-- | 7       | 2020-01-04 13:57:59 |
-- | 2       | 2020-07-29 23:09:44 |
-- | 6       | 2020-12-09 10:39:37 |
-- +---------+---------------------+
-- Confirmations table:
-- +---------+---------------------+-----------+
-- | user_id | time_stamp          | action    |
-- +---------+---------------------+-----------+
-- | 3       | 2021-01-06 03:30:46 | timeout   |
-- | 3       | 2021-07-14 14:00:00 | timeout   |
-- | 7       | 2021-06-12 11:57:29 | confirmed |
-- | 7       | 2021-06-13 12:58:28 | confirmed |
-- | 7       | 2021-06-14 13:59:27 | confirmed |
-- | 2       | 2021-01-22 00:00:00 | confirmed |
-- | 2       | 2021-02-28 23:59:59 | timeout   |
-- +---------+---------------------+-----------+
-- Output:
-- +---------+-------------------+
-- | user_id | confirmation_rate |
-- +---------+-------------------+
-- | 6       | 0.00              |
-- | 3       | 0.00              |
-- | 7       | 1.00              |
-- | 2       | 0.50              |
-- +---------+-------------------+
-- Explanation:
-- User 6 did not request any confirmation messages. The confirmation rate is 0.
-- User 3 made 2 requests and both timed out. The confirmation rate is 0.
-- User 7 made 3 requests and all were confirmed. The confirmation rate is 1.
-- User 2 made 2 requests where one was confirmed and the other timed out. The confirmation rate is 1 / 2 = 0.5.


SELECT
    s.user_id,
    ROUND(SUM(CASE WHEN action = 'confirmed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS confirmation_rate
FROM Signups AS s
LEFT JOIN Confirmations AS c
    ON s.user_id = c.user_id
GROUP BY s.user_id;

-- Saved exactly as it passed both oracles, including the unqualified `action`.
-- It binds because only Confirmations has that column, but the repo convention
-- and the JOIN-grammar card both say every reference is alias.column once the
-- tables are aliased. Left as-run rather than tidied; the file records what ran.
--
-- Three defects, none of which DuckDB objected to:
--   1. ROUND(x) with ONE argument rounds to zero decimals, so every rate came
--      back 0.0 or 1.0. User 2's 1/2 printed as 1.0. Users 3 and 7 were right
--      by accident, so only user 2 exposed it. The `, 2` had been written in a
--      later attempt and not carried back.
--   2. COUNT(action) as the denominator returned 0 for user 6, who signed up
--      and never confirmed, giving 0/0 = -nan. COUNT(col) counts non-NULLs;
--      COUNT(*) counts rows, and the LEFT JOIN leaves user 6 exactly one
--      NULL-filled row. This is worked-example step 5, parked at the time.
--   3. Mid-problem the join direction was swapped to FROM Confirmations LEFT
--      JOIN Signups, which silently dropped user 6 from the output entirely.
--      Reverted. The join-side card is the one card passed in this session's
--      review, and it still regressed under load.
--
-- Dead end worth recording: several attempts tried to nest an aggregate inside
-- another aggregate, SUM(... SUM(...) ...). That is illegal in every engine and
-- no arrangement of parens fixes it.
