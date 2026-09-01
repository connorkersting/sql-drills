-- source: leetcode 1873 https://leetcode.com/problems/calculate-special-bonus/
-- problem: Calculate Special Bonus (Easy) [Database]
-- pattern: conditional expression (CASE WHEN in the SELECT list)
-- date: 2026-08-31
-- minutes taken: 21 (2026-08-31), 0 hints
-- solved unaided (y/n): n -- worked example granted (we=1); both defects surfaced by the coached spec check

-- Table: Employees
--
-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | employee_id | int     |
-- | name        | varchar |
-- | salary      | int     |
-- +-------------+---------+
-- employee_id is the primary key (column with unique values) for this table.
-- Each row of this table indicates the employee ID, employee name, and salary.
--
-- Write a solution to calculate the bonus of each employee. The bonus of an employee is 100% of their salary if the ID of the employee is an odd number and the employee's name does not start with the character 'M'. The bonus of an employee is 0 otherwise.
--
-- Return the result table ordered by employee_id.
--
-- The result format is in the following example.
--
-- Example 1:
--
-- Input:
-- Employees table:
-- +-------------+---------+--------+
-- | employee_id | name    | salary |
-- +-------------+---------+--------+
-- | 2           | Meir    | 3000   |
-- | 3           | Michael | 3800   |
-- | 7           | Addilyn | 7400   |
-- | 8           | Juan    | 6100   |
-- | 9           | Kannon  | 7700   |
-- +-------------+---------+--------+
-- Output:
-- +-------------+-------+
-- | employee_id | bonus |
-- +-------------+-------+
-- | 2           | 0     |
-- | 3           | 0     |
-- | 7           | 7400  |
-- | 8           | 0     |
-- | 9           | 7700  |
-- +-------------+-------+
-- Explanation:
-- The employees with IDs 2 and 8 get 0 bonus because they have an even employee_id.
-- The employee with ID 3 gets 0 bonus because their name starts with 'M'.
-- The rest of the employees get a 100% bonus.


SELECT
    employee_id,
    CASE WHEN employee_id % 2 = 1 AND name NOT LIKE 'M%' THEN salary ELSE 0 END AS bonus
FROM Employees
ORDER BY employee_id;

-- Two defects in the first run, neither caught by DuckDB, both caught by reading
-- the spec against the output: salary * 2 instead of salary ("100% of salary"
-- means salary), and no ORDER BY though the spec says "ordered by employee_id".
-- The rows came out ordered anyway on this sample, so the sort defect was
-- invisible in the output and only the wording exposed it.
-- Parser error "syntax error at or near """ on the first attempt was a
-- non-ASCII character from a paste, not SQL. Retyping the line fixed it.
