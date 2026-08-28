-- Sample data for Queries Quality and Percentage (leetcode 1211)
-- Generated from the problem statement by get.ps1. Sample rows only,
-- not the judge's full test data. A query that passes here can still fail.

DROP TABLE IF EXISTS Queries;
CREATE TABLE Queries (
    query_name VARCHAR,
    result VARCHAR,
    position INTEGER,
    rating INTEGER
);
INSERT INTO Queries (query_name, result, position, rating) VALUES
    ('Dog', 'Golden Retriever', 1, 5),
    ('Dog', 'German Shepherd', 2, 5),
    ('Dog', 'Mule', 200, 1),
    ('Cat', 'Shirazi', 5, 2),
    ('Cat', 'Siamese', 3, 3),
    ('Cat', 'Sphynx', 7, 4);

