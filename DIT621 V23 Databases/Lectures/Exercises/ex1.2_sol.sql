--  psql -v ON_ERROR_STOP=1 -U postgres portal

-- Deletes everything to make this file re-runnable
\set QUIET true
SET client_min_messages TO NOTICE;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false


-- a) Tables
-- Items (_itemname_, price)
CREATE TABLE Items (
  itemname CHAR(20) PRIMARY KEY,
  price FLOAT NOT NULL check (price >= 0) );

-- Categories (catname)
CREATE TABLE Categories (
  catname CHAR(10) PRIMARY KEY );

-- Categorized(item, category)
--   category → Categories.catname
--   item → Items.itemname
CREATE TABLE Categorized (
  item CHAR(20) PRIMARY KEY REFERENCES Items,
  category CHAR(10) NOT NULL REFERENCES Categories );

-- Discounts (category, pricefactor)
--  category → Categories.catname
CREATE TABLE Discounts (
  category CHAR(10) PRIMARY KEY REFERENCES Categories,
  pricefactor FLOAT NOT NULL check (pricefactor >= 0 AND pricefactor <= 1));


-- We insert some elements
INSERT INTO Items VALUES ('chair', 550);
INSERT INTO Items VALUES ('table', 1550);
INSERT INTO Items VALUES ('lamp', 120);
INSERT INTO Items VALUES ('flower pot', 50);
INSERT INTO Items VALUES ('trousers', 200);
INSERT INTO Items VALUES ('coat', 440);
INSERT INTO Items VALUES ('skirt', 150);

INSERT INTO Categories VALUES ('furniture');
INSERT INTO Categories VALUES ('clothes');
INSERT INTO Categories VALUES ('electrical');

INSERT INTO Categorized VALUES ('chair', 'furniture');
INSERT INTO Categorized VALUES ('table', 'furniture');
INSERT INTO Categorized VALUES ('trousers', 'clothes');
INSERT INTO Categorized VALUES ('coat', 'clothes');
INSERT INTO Categorized VALUES ('skirt', 'clothes');

INSERT INTO Discounts VALUES ('clothes', 0.75);

/* If you want to see what is in the tables uncomment this
SELECT * FROM Items;
SELECT * FROM Categories;
SELECT * FROM Categorized;
SELECT * FROM Discounts;
*/


-- b)
-- Not yet what is asked: this gives the categories which have some discount
SELECT item, pricefactor
FROM Categorized NATURAL JOIN Discounts;

-- LEFT OUTER so all Items are in
-- COALESCE for those items without a pricefactor
-- Try with just SELECT itemname, price*pricefactor AS price
SELECT itemname, price*COALESCE(pricefactor,1) AS price
FROM Items LEFT OUTER JOIN (Categorized NATURAL JOIN Discounts)
ON item = itemname;


-- c)
-- Creates the difference in price per category and then selects the max value
WITH DiffPriceCategory AS 
     (SELECT category, (MAX(price) - MIN(price)) AS diffprice
      FROM Categorized JOIN Items ON item = itemname
      GROUP BY category)
SELECT MAX(diffprice) FROM DiffPriceCategory;

-- Alternative: Creates the full cartesean product per category
-- and then selects the max difference in price
WITH ItemsWithCats AS
     (SELECT category, item, price
      FROM Items JOIN Categorized ON item=itemname)
SELECT MAX(A.price-B.price)
FROM ItemsWithCats AS A JOIN ItemsWithCats AS B USING (category);


-- d) 
SELECT AVG(price) as average_price
FROM Items 
WHERE itemname NOT IN (SELECT item FROM Categorized);

-- Alternative and less elegant way
SELECT AVG(price) AS average_price
FROM Items LEFT OUTER JOIN Categorized ON item = itemname
WHERE category IS NULL;
