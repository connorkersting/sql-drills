-- Sample data for Replace Employee ID With The Unique Identifier (leetcode 1378)
-- Generated from the problem statement by get.ps1. Sample rows only,
-- not the judge's full test data. A query that passes here can still fail.

DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees (
    id INTEGER,
    name VARCHAR
);
INSERT INTO Employees (id, name) VALUES
    (1, 'Alice'),
    (7, 'Bob'),
    (11, 'Meir'),
    (90, 'Winston'),
    (3, 'Jonathan');

DROP TABLE IF EXISTS EmployeeUNI;
CREATE TABLE EmployeeUNI (
    id INTEGER,
    unique_id INTEGER
);
INSERT INTO EmployeeUNI (id, unique_id) VALUES
    (3, 1),
    (11, 2),
    (90, 3);

