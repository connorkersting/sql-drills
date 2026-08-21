-- Sample data for Product Sales Analysis I (leetcode 1068)
-- Generated from the problem statement by get.ps1. Sample rows only,
-- not the judge's full test data. A query that passes here can still fail.

DROP TABLE IF EXISTS Sales;
CREATE TABLE Sales (
    sale_id INTEGER,
    product_id INTEGER,
    year INTEGER,
    quantity INTEGER,
    price INTEGER
);
INSERT INTO Sales (sale_id, product_id, year, quantity, price) VALUES
    (1, 100, 2008, 10, 5000),
    (2, 100, 2009, 12, 5000),
    (7, 200, 2011, 15, 9000);

DROP TABLE IF EXISTS Product;
CREATE TABLE Product (
    product_id INTEGER,
    product_name VARCHAR
);
INSERT INTO Product (product_id, product_name) VALUES
    (100, 'Nokia'),
    (200, 'Apple'),
    (300, 'Samsung');

