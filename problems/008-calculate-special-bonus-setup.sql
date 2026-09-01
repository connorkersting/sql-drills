-- Sample data for Calculate Special Bonus (leetcode 1873)
-- Generated from the problem statement by get.ps1. Sample rows only,
-- not the judge's full test data. A query that passes here can still fail.

DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees (
    employee_id INTEGER,
    name VARCHAR,
    salary INTEGER
);
INSERT INTO Employees (employee_id, name, salary) VALUES
    (2, 'Meir', 3000),
    (3, 'Michael', 3800),
    (7, 'Addilyn', 7400),
    (8, 'Juan', 6100),
    (9, 'Kannon', 7700);

