-- Sample data for Monthly Transactions I (leetcode 1193)
-- Generated from the problem statement by get.ps1. Sample rows only,
-- not the judge's full test data. A query that passes here can still fail.

DROP TABLE IF EXISTS Transactions;
CREATE TABLE Transactions (
    id INTEGER,
    country VARCHAR,
    state VARCHAR,
    amount INTEGER,
    trans_date DATE
);
INSERT INTO Transactions (id, country, state, amount, trans_date) VALUES
    (121, 'US', 'approved', 1000, '2018-12-18'),
    (122, 'US', 'declined', 2000, '2018-12-19'),
    (123, 'US', 'approved', 2000, '2019-01-01'),
    (124, 'DE', 'approved', 2000, '2019-01-07');

