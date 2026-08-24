-- Sample data for Rising Temperature (leetcode 197)
-- Generated from the problem statement by get.ps1. Sample rows only,
-- not the judge's full test data. A query that passes here can still fail.

DROP TABLE IF EXISTS Weather;
CREATE TABLE Weather (
    id INTEGER,
    recordDate DATE,
    temperature INTEGER
);
INSERT INTO Weather (id, recordDate, temperature) VALUES
    (1, '2015-01-01', 10),
    (2, '2015-01-02', 25),
    (3, '2015-01-03', 20),
    (4, '2015-01-04', 30);

