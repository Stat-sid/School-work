-- To start postgreSQL in the terminal
-- psql -v ON_ERROR_STOP=1 -U postgres portal

-- OBS: Deletes everything!
\c portal
\set QUIT true
SET client_min_messages TO WARNING;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false


---------------------- Testing SERIAL datatype ------------------------

CREATE TABLE SPeople (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE);

INSERT INTO SPeople (name) VALUES ('Ana');
INSERT INTO SPeople VALUES (DEFAULT, 'Pedro');
SELECT * FROM SPeople;

DELETE FROM SPeople WHERE name = 'Ana';
SELECT * FROM SPeople;

INSERT INTO SPeople (name) VALUES ('Jan') RETURNING id;
SELECT * FROM SPeople;

/*
-- Will give an error
UPDATE SPeople SET name = 'Pedro'
WHERE id = 3;
*/

UPDATE SPeople SET id = 1 WHERE id = 3;
INSERT INTO SPeople VALUES (DEFAULT, 'Lilly');
INSERT INTO SPeople (name) VALUES ('Ana');
SELECT * FROM SPeople;


---------------------- Table with a time stamp ------------------------

CREATE TABLE Reports (
  id TEXT PRIMARY KEY,
  descr TEXT NOT NULL,
  tstamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP );

INSERT INTO Reports VALUES ('1', 'car accident');

SELECT * FROM Reports;

SELECT id, descr, date(tstamp) FROM Reports
WHERE date_part('year', CURRENT_DATE) = date_part('year', tstamp);


---------------------- Table with unique attributes ------------------------

CREATE TABLE Students (
  idNumber TEXT PRIMARY KEY,
  name TEXT,
  cid CHAR(7),
  UNIQUE (cid) );

-- Problems with inserting the third student
INSERT INTO Students VALUES ('1','Ana Lia','analia');
INSERT INTO Students VALUES ('2','Ana Maria','anama');
--INSERT INTO Students VALUES ('3','Analia','analia');


---------------------- Table with compund primary key ------------------------
-- When referencing to a primary key one can ommit the attribute

CREATE TABLE Grades (
  course CHAR(6),
  stid TEXT REFERENCES Students,
  grade INT CHECK (grade >= 0 AND grade <= 5),
  PRIMARY KEY (course, stid) );

INSERT INTO Grades VALUES ('TDA357', '1', 3);
INSERT INTO Grades VALUES ('TDA357', '2', 0);
INSERT INTO Grades VALUES ('TDA552', '2', 4);


---------------------- Table with a constraint comparing two attributes ------

CREATE TABLE Products (
  product_no INT PRIMARY KEY,
  name TEXT,
  price NUMERIC CHECK (price > 0),
  discounted_price NUMERIC CHECK (discounted_price > 0),
  CONSTRAINT ok_discount CHECK (price > discounted_price) );


---------------------- Aliasing -------------------------

SELECT S.name, G.course, G.grade
FROM Students AS S, Grades AS G
WHERE S.idNumber = G.stid;

-- In this case same as
SELECT name, course, grade
FROM Students JOIN Grades ON idNumber = stid;

