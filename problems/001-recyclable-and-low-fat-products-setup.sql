-- Sample data for Recyclable and Low Fat Products (leetcode 1908)
-- Generated from the problem statement by get.ps1. Sample rows only,
-- not the judge's full test data. A query that passes here can still fail.

DROP TABLE IF EXISTS Products;
CREATE TABLE Products (
    product_id INTEGER,
    low_fats VARCHAR,
    recyclable VARCHAR
);
INSERT INTO Products (product_id, low_fats, recyclable) VALUES
    (0, 'Y', 'N'),
    (1, 'Y', 'Y'),
    (2, 'N', 'Y'),
    (3, 'Y', 'Y'),
    (4, 'N', 'N');

