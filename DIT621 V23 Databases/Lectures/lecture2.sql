/* 

-- Working with PostgresSQL

-- Creates a new database
> createdb MyDataBase

-- Connects to the database and starts the SQL interpreter
> psql MyDataBase

-- two ways to disconnect from the database:
MyDataBase=# quit
-- or
MyDataBase=# \q

-- Deletes the database
> dropdb MyDataBase
*/


/*
-- To start postgreSQL in the terminal: 
--   we connect with database "portal" as user "postgres"
-- Will stop if it finds an error
psql -v ON_ERROR_STOP=1 -U postgres portal
*/


-- OBS: Deletes everything!
-- Good if you want to clean your database (otherwise not very good :)
\c portal
\set QUIT true
SET client_min_messages TO NOTICE;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false


---------------------- Create tables ------------------------

-- Schema: Countries (_name_, capital, area, population, continent, currency) 
CREATE TABLE Countries (
  name TEXT PRIMARY KEY,
  abbr CHAR(2) NOT NULL UNIQUE,
  capital TEXT NOT NULL,
  area FLOAT NOT NULL,
  population INT NOT NULL CHECK (population >= 0),
  continent VARCHAR(10) NOT NULL,
  currency CHAR(3),
  CONSTRAINT none_sense CHECK (area > population * 10) );


-- New table CoureGrades
/*
-- Bad table: multiple primary keys!
CREATE TABLE CourseGrades (
  student TEXT PRIMARY KEY,
  course CHAR(6) PRIMARY KEY,
  grade INT DEFAULT 0 CHECK (grade IN (0,3,4,5)));
*/

-- This is how we define compound primary keys
-- Schema: CourseGrades (_student_, _course_, grade)
CREATE TABLE CourseGrades (
  student TEXT,
  course CHAR(6),
  grade INT DEFAULT 0,
  CONSTRAINT okgrade CHECK (grade IN (0,3,4,5)),
  PRIMARY KEY (student, course));


---------------------- Alter tables ------------------------

-- Changing the type of a column
ALTER TABLE Countries ALTER COLUMN continent TYPE CHAR(2);

-- Adding a column
ALTER TABLE Countries ADD language TEXT;

-- Disallowing empty values
ALTER TABLE Countries ALTER COLUMN language SET NOT NULL;

-- Check table description
\d Countries

-- Actually we don't want this column after all!
ALTER TABLE Countries DROP COLUMN language;

-- Check table description
\d Countries

-- Removing a constraint
ALTER TABLE Countries DROP CONSTRAINT none_sense;

-- Check table description
\d Countries


---------------------- Drop tables ------------------------

-- We remove the table
DROP TABLE CourseGrades;

-- Deleting a table that doesn't exists will not work
--DROP TABLE Contacts;
-- This will work
DROP TABLE IF EXISTS Contacts;


---------------------- Insert values into tables ------------------------

-- We instert some data
INSERT INTO Countries
VALUES ('Denmark', 'DK', 'Copenhagen', 43094, 5484000, 'EU', 'DKK');
INSERT INTO Countries
VALUES ('Sweden', 'SE', '' , -449964, 9555893, 'EU', NULL);

/*
-- This insert will not work because:

-- We already have a country named Sweden!
INSERT INTO Countries
VALUES ('Sweden', 'SE', 'Stochkolm' , 449964, 9555893, 'EU', 'SEK');
-- The primary key (name) cannot be empty
INSERT INTO Countries
VALUES (NULL, 'SA', 'BsAs' , 1780400, 44938712, 'AM', 'ARS');
-- The continent cannot be empty!
INSERT INTO Countries
VALUES ('SmallArgentina', 'SA', 'BsAs' , 1780400, 44938712, NULL, 'ARS');
-- Abbreviations should be unique!
INSERT INTO Countries
VALUES ('BigDen', 'DK', 'BigCop', 43094000, 5484000, 'EU', 'DKK');
-- Negative population
INSERT INTO Countries
VALUES ('Perú', 'PE', 'Lima' , 1285216, -32824358, 'AM', 'SOL');
*/


-- Inserting more data
INSERT INTO Countries
VALUES ('Estonia', 'EE', 'Tallinn', 45226, 1291170, 'EU', 'EUR');
INSERT INTO Countries
VALUES ('Finland', 'FI', 'Helsinki', 337030, 5244000, 'EU', 'EUR');
INSERT INTO Countries
VALUES ('Norway', 'NO', 'Oslo', 324220.5, 5009150, 'EU', 'NOK');
INSERT INTO Countries
VALUES ('Uruguay', 'UY', 'Montevideo' , 176215, 3518552, '', 'UYU');
INSERT INTO Countries
VALUES ('Ecuador', 'EC', 'Quito' , 283561, 17084358, 'AM', 'USD');
INSERT INTO Countries
VALUES ('Argentina', 'AR', 'Buenos Aires' , 2780400, 44938712, 'AM', 'ARS');
INSERT INTO Countries
VALUES ('NewUruguay', 'NU', 'MVD' , 176215, 44938712, 'AM', 'UYU');
INSERT INTO Countries
VALUES ('SmallArgentina', 'SA', 'BsAs' , 1780400, 44938712, 'AM', 'ARS');
INSERT INTO Countries
VALUES ('Perú', 'PE', 'Lima' , -449964, 32824358, 'AM', 'SOL');


---------------------- Modify the table when there is data ----------------

-- Check table description
\d Countries

-- What happen if we now change the type of a column?
ALTER TABLE Countries ALTER COLUMN continent TYPE CHAR(3);

-- Values in the table have more than one char so this is not possible
--ALTER TABLE Countries ALTER COLUMN continent TYPE CHAR(1);

-- We change it back because there is only two non empty chars in the column!
ALTER TABLE Countries ALTER COLUMN continent TYPE CHAR(2);


---------------------- Pattern matching ------------------------

CREATE TABLE Teachers (
  idnr TEXT PRIMARY KEY
  CHECK (idnr LIKE '______-____'),
  name TEXT
  CHECK (name LIKE '% %'),
  phone TEXT NOT NULL,
  CHECK (phone SIMILAR TO '[0-9]{10}') );

INSERT INTO Teachers VALUES ('123456-7890', 'Ana Bove', '0123456789');
/* -- THese insters will give errors
INSERT INTO Teachers VALUES ('1234567890', 'Ana Bove', '0123456789');
INSERT INTO Teachers VALUES ('213456-7890', 'Ana-Bove', '0123456789');
INSERT INTO Teachers VALUES ('213456-7890', 'Ana Bove', '012345');
INSERT INTO Teachers VALUES ('213456-7890', 'Ana Bove', 'no phone !');
*/

DROP TABLE Teachers;


---------------------- Querying tables ------------------------

SELECT * FROM Countries;

SELECT name, capital FROM Countries;

SELECT * FROM Countries WHERE name='Sweden' OR name='Uruguay';

SELECT name, capital
FROM Countries WHERE area > 0 AND name IN ('Sweden', 'Uruguay');


---------------------- Playing with the output ------------------------

SELECT name, population FROM Countries
ORDER BY population;

SELECT name, population FROM Countries
ORDER BY population ASC;

SELECT name, population FROM Countries
ORDER BY population DESC;

SELECT name, population FROM Countries
ORDER BY population DESC
LIMIT 5;

SELECT continent FROM Countries;

SELECT DISTINCT continent FROM Countries;


---------------------- Quiz ------------------------

SELECT * FROM Countries;

-- Will the result by the same?
-- ORDER BY attr1, attr2 will first order by attr1 and then by attr2
SELECT name, area, population FROM Countries
WHERE continent != 'EU'
ORDER BY area, population;

-- Compare with 
SELECT name, area, population FROM Countries
WHERE continent != 'EU'
ORDER BY population, area;


-- Will the result by the same?
SELECT name, abbr FROM Countries
WHERE continent != 'EU';

-- Compare with 
-- the SELECT part takes place last
SELECT name, abbr FROM Countries
WHERE continent != 'EU'
ORDER BY population, area;


---------------------- Modifying data in tables ------------------------

SELECT * FROM Countries;

UPDATE Countries SET continent = 'AM'
WHERE name = 'Uruguay';

UPDATE Countries
SET area = -area, capital = 'Stockholm', currency = 'SEK'
WHERE name = 'Sweden';

UPDATE Countries SET population = population + 10
WHERE continent = 'EU';

SELECT * FROM Countries;


---------------------- Deleting data from tables ------------------------

DELETE FROM Countries WHERE name IN ('SmallArgentina', 'NewUruguay');

DELETE FROM Countries WHERE continent = 'AM' AND area <= 0;

SELECT * FROM Countries;

-- Deletes ALL the data!
--DELETE FROM Countries;


---------------------- Computing while querying ------------------------

SELECT name, population/area FROM Countries;

SELECT name, FLOOR(population/area) AS density FROM Countries;

SELECT name, ROUND(population/area) AS density
FROM countries
WHERE continent = 'EU'
ORDER BY population/area DESC
LIMIT 3;

SELECT name, ROUND(population/area) AS density
FROM countries
WHERE continent = 'EU'
ORDER BY density DESC
LIMIT 3;


---------------------- Aggregations ------------------------

SELECT COUNT(*) FROM Countries;

SELECT COUNT(name) FROM Countries WHERE population > 10000000;

SELECT COUNT(name), SUM(population) FROM Countries;


---------------------- Combining Group by and Aggregations ------------------

SELECT continent FROM Countries GROUP BY continent;

-- Compare with
SELECT continent FROM Countries;

SELECT continent, COUNT(name)
FROM Countries
GROUP BY continent;

SELECT continent, SUM(population), AVG(population)::Numeric(10,2) AS average
FROM Countries
GROUP BY continent;

-- Will not work!
--SELECT continent, name FROM Countries GROUP BY continent;


---------------------- More on Aggregations ------------------------

SELECT COUNT(*) FROM Countries WHERE currency='EUR';

SELECT currency, COUNT(name)
FROM Countries
WHERE population < 10000000
GROUP BY currency;

/*
-- Will not work!
SELECT currency, COUNT(name)
FROM Countries
GROUP BY currency
WHERE population < 10000000;
*/

SELECT currency, COUNT(name)
FROM Countries
GROUP BY currency
HAVING COUNT(name) > 1;

/*
-- Will not work!
SELECT currency, COUNT(name)
FROM Countries
HAVING COUNT(name) > 1
GROUP BY currency;
*/

---------------------- Computing with Select ------------------------

SELECT 'Hello world!';

SELECT 2+3;

SELECT 2+3 AS answer;

SELECT 2+3 AS sum, 2*3 AS product;

SELECT 2+3 WHERE 2+2 = 5;

SELECT 2+3 WHERE true;

SELECT ;

---------------------- Now we can delete! ------------------------

-- Deletes ALL the data!
DELETE FROM Countries;

-- The table is still there
\d Countries

-- We now delete the table
DROP TABLE Countries;

-- Now this gives an error
--\d Countries
