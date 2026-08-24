-- Sample data for Employee Bonus (leetcode 577)
-- Generated from the problem statement by get.ps1. Sample rows only,
-- not the judge's full test data. A query that passes here can still fail.

DROP TABLE IF EXISTS Employee;
CREATE TABLE Employee (
    empId INTEGER,
    name VARCHAR,
    supervisor INTEGER,
    salary INTEGER
);
INSERT INTO Employee (empId, name, supervisor, salary) VALUES
    (3, 'Brad', NULL, 4000),
    (1, 'John', 3, 1000),
    (2, 'Dan', 3, 2000),
    (4, 'Thomas', 3, 4000);

DROP TABLE IF EXISTS Bonus;
CREATE TABLE Bonus (
    empId INTEGER,
    bonus INTEGER
);
INSERT INTO Bonus (empId, bonus) VALUES
    (2, 500),
    (4, 2000);

