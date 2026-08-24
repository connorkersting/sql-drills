-- Sample data for Customer Who Visited but Did Not Make Any Transactions (leetcode 1581)
-- Generated from the problem statement by get.ps1. Sample rows only,
-- not the judge's full test data. A query that passes here can still fail.

DROP TABLE IF EXISTS Visits;
CREATE TABLE Visits (
    visit_id INTEGER,
    customer_id INTEGER
);
INSERT INTO Visits (visit_id, customer_id) VALUES
    (1, 23),
    (2, 9),
    (4, 30),
    (5, 54),
    (6, 96),
    (7, 54),
    (8, 54);

DROP TABLE IF EXISTS Transactions;
CREATE TABLE Transactions (
    transaction_id INTEGER,
    visit_id INTEGER,
    amount INTEGER
);
INSERT INTO Transactions (transaction_id, visit_id, amount) VALUES
    (2, 5, 310),
    (3, 5, 300),
    (9, 5, 200),
    (12, 1, 910),
    (13, 2, 970);

