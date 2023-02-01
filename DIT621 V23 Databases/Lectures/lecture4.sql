/*
psql -v ON_ERROR_STOP=1 -U postgres portal
*/

-- OBS: Deletes everything!
\c portal
\set QUIT true
SET client_min_messages TO NOTICE;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false


---------------------- Recall running table ---------------------

-- Recall tables
CREATE TABLE Countries (
  name TEXT PRIMARY KEY,
  abbr CHAR(2) NOT NULL UNIQUE,
  capital TEXT NOT NULL UNIQUE,
  area FLOAT NOT NULL,
  population INT NOT NULL CHECK (population >= 0),
  continent CHAR(2) NOT NULL,
  currency CHAR(3));

CREATE TABLE Currencies (
  code CHAR(3) PRIMARY KEY,
  name TEXT,
  value FLOAT);

-- Running data
INSERT INTO Countries
VALUES ('Denmark', 'DK', 'Copenhagen', 43094, 5484000, 'EU', 'DKK');
INSERT INTO Countries
VALUES ('Sweden', 'SE', 'Stockholm' , 449964, 9555893, 'EU', 'SEK');
INSERT INTO Countries
VALUES ('Estonia', 'EE', 'Tallinn', 45226, 1291170, 'EU', 'EUR');
INSERT INTO Countries
VALUES ('Finland', 'FI', 'Helsinki', 337030, 5244000, 'EU', 'EUR');
INSERT INTO Countries
VALUES ('Norway', 'NO', 'Oslo', 324220.5, 5009150, 'EU', 'NOK');
INSERT INTO Countries
VALUES ('Uruguay', 'UY', 'Montevideo' , 176215, 3518552, 'AM', 'UYU');
INSERT INTO Countries
VALUES ('Ecuador', 'EC', 'Quito' , 283561, 17084358, 'AM', 'USD');
INSERT INTO Countries
VALUES ('Argentina', 'AR', 'Buenos Aires' , 2780400, 44938712, 'AM', 'ARS');

INSERT INTO Currencies VALUES ('SEK','Swedish Krona', 1.00);
INSERT INTO Currencies VALUES ('DKK','Danish Krone', 1.36);
INSERT INTO Currencies VALUES ('EUR','Euro', 10.17);
INSERT INTO Currencies VALUES ('ARS','Peso Argentino', 0.1);
INSERT INTO Currencies VALUES ('UYU','Peso Uruguayo', 0.2);
INSERT INTO Currencies VALUES ('USD','Dollar', 8.28);
INSERT INTO Currencies VALUES ('BTC','Bitcoin', 85634.34);


---------------------- Foreign keys -------------------------

-- There are countries whose currency in not the in Currencies table
SELECT DISTINCT currency AS code
FROM Countries
WHERE currency NOT IN (SELECT code FROM Currencies);

/*
-- A currency missing, hence adding this reference will give us an error
ALTER TABLE Countries
ADD FOREIGN KEY (currency) REFERENCES Currencies (code);
*/

-- We add the missing values

-- An alternative direct insert
-- INSERT INTO Currencies VALUES ('NOK', 'Norwegian Krone', 0.96);

-- Insert values using a query
INSERT INTO Currencies 
   (SELECT DISTINCT currency AS code
    FROM Countries
    WHERE currency NOT IN (SELECT code FROM Currencies) );

UPDATE Currencies
SET name = 'Norwegian Krone', value =  0.96
WHERE code = 'NOK';

-- We add the reference to Currencies
ALTER TABLE Countries
ADD FOREIGN KEY (currency) REFERENCES Currencies (code);

-- Now we cannot delete table Currencies since it is referred to from Countries
-- DROP TABLE Currencies;


---------------------- Compound foreign keys -------------------------

CREATE TABLE Cities (
  name TEXT,
  country TEXT,
  PRIMARY KEY (name, country) );

CREATE TABLE CountryCapitals (
  name TEXT PRIMARY KEY,
  capital TEXT,
  FOREIGN KEY (capital, name) REFERENCES Cities );

-- Alternative
-- CREATE TABLE CountryCapitals (
-- ...
-- FOREIGN KEY (capital, name) REFERENCES Cities (name, country) );


---------------------- Mutual References  -------------------------

/* Mutual references are not allowed
CREATE TABLE NewCities (
  name TEXT,
  country TEXT REFERENCES NewCountryCapitals,
  PRIMARY KEY (name, country) );

CREATE TABLE NewCountryCapitals (
  name TEXT PRIMARY KEY,
  capital TEXT,
  FOREIGN KEY (capital, name) REFERENCES NewCities );
*/

-- Instead we add the extra foreign key
ALTER TABLE Cities
ADD FOREIGN KEY (country) REFERENCES CountryCapitals;

-- Inserting values

-- Neither of these will work
-- INSERT INTO CountryCapitals VALUES ('Sweden', 'Stockholm');
-- INSERT INTO Cities VALUES ('Stockholm','Sweden');

-- We need all this instead
INSERT INTO CountryCapitals VALUES ('Sweden', NULL);

INSERT INTO Cities VALUES ('Stockholm', 'Sweden');

UPDATE CountryCapitals SET capital = 'Stockholm'
WHERE name = 'Sweden';

/*
-- Not possible
UPDATE CountryCapitals SET name = 'Republic of Sweden'
WHERE name = 'Sweden';
*/

-- Neither of these will work
-- DROP TABLE Cities;
-- DROP TABLE CountryCapitals;

-- We need to do this instead (or the other order around)
DROP TABLE Cities CASCADE;

-- Now this will work
DROP TABLE CountryCapitals;

---------------------- Cascade -------------------------

-- OBS: since capital and country are (part of) the primary key
-- other options (RESTRIC/SET NULL) will actually imply no changes are allowed!
CREATE TABLE Cities (
  name TEXT,
  country TEXT,
  PRIMARY KEY (name, country) );

CREATE TABLE CountryCapitals (
  name TEXT PRIMARY KEY,
  capital TEXT,
  FOREIGN KEY (capital, name) REFERENCES Cities
  ON DELETE CASCADE ON UPDATE CASCADE);

ALTER TABLE Cities
ADD FOREIGN KEY (country) REFERENCES CountryCapitals
ON DELETE CASCADE ON UPDATE CASCADE;

-- We insert
INSERT INTO CountryCapitals VALUES ('Sweden', NULL);
INSERT INTO Cities VALUES ('Stockholm', 'Sweden');
UPDATE CountryCapitals SET capital = 'Stockholm'
WHERE name = 'Sweden';

-- We change the name of the country
UPDATE CountryCapitals SET name = 'Republic of Sweden'
WHERE name = 'Sweden';

-- It even changed the table for cities
SELECT * FROM Cities;

-- Changing the name of the city
UPDATE Cities SET name = 'New Stockholm'
WHERE name = 'Stockholm';

SELECT * FROM CountryCapitals;


-- Here neither sender nor receive are part of the primary key!
-- ON DELETE RESTRICT will give an error!
CREATE TABLE Accounts (
  id CHAR(6) PRIMARY KEY,
  name TEXT NOT NULL,
  balance INT CHECK (balance >= 0) );

CREATE TABLE Transfers (
  id INT PRIMARY KEY,
  sender CHAR(6) REFERENCES Accounts ON DELETE RESTRICT ON UPDATE RESTRICT,
  receiver CHAR(6) REFERENCES Accounts ON DELETE SET NULL ON UPDATE SET NULL,
  amount INT CHECK (amount > 0),
  CHECK (receiver != sender) );

INSERT INTO Accounts VALUES ('123456', 'Ana', 10000);
INSERT INTO Accounts VALUES ('234567', 'Peter', 20000);
INSERT INTO Accounts VALUES ('345678', 'John', 1500);
INSERT INTO Accounts VALUES ('456789', 'Sofia', 5000);
INSERT INTO Accounts VALUES ('567890', 'Jonas', 5000);

INSERT INTO Transfers VALUES (1, '123456', '234567', 2000);
INSERT INTO Transfers VALUES (2, '123456', '456789', 3000);
INSERT INTO Transfers VALUES (3, '345678', '234567', 1500);
INSERT INTO Transfers VALUES (4, '345678', '456789', 500);

SELECT * FROM Transfers;

/*
-- Will give error because of the UPDATE RESTRICT on sender
UPDATE Accounts SET id = '246801'
WHERE id = '123456';

-- Will give error because of the DELETE RESTRICT on sender
DELETE FROM Accounts 
WHERE id = '123456';
*/

-- Changes in the receivers are set to null
UPDATE Accounts SET id = '246801'
WHERE id = '234567';

-- Deletion in the receivers are set to null
DELETE FROM Accounts 
WHERE id = '456789';

-- All receivers are now null!
SELECT * FROM Transfers;


---------------------- Foreign keys must refer to unique values ---------------

-- Observe the choice of primary key here
CREATE TABLE BadCurrencies (
  code CHAR(3),
  name TEXT PRIMARY KEY,
  value FLOAT);

/*
-- This will not be allowed since we want to refer to a
-- (possible) non-unique value: how do we know which one we actually refer to?
CREATE TABLE BadCountries (
  name TEXT PRIMARY KEY,
  capital TEXT NOT NULL UNIQUE,
  currency CHAR(3) REFERENCES BadCurrencies (code));
*/
