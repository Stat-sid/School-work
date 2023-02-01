-- psql -v ON_ERROR_STOP=1 -U postgres portal

-- Deletes everything to make this file re-runnable
\set QUIET true
SET client_min_messages TO NOTICE;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false


-- a) Tables
--Clients (_name_, email, phonenr)
CREATE TABLE Clients (
  name CHAR(20) PRIMARY KEY,
  email TEXT NOT NULL,
  phonenr INT NOT NULL CHECK (phonenr > 0));

--Pets (_chipnr_, name, owner, type, born)
--  owner → Client.name
--  type ∈ {dog, cat, rabbit}
CREATE TABLE Pets (
  chipnr INT PRIMARY KEY,
  name TEXT NOT NULL,
  owner CHAR(20) NOT NULL REFERENCES Clients,
  type TEXT CHECK (type IN ('dog', 'cat', 'rabbit')),
  born INT NOT NULL
  CHECK (born >= 2000 AND born <= date_part('year', CURRENT_DATE)));

--Vets (_id_, name, phonenr, specialisation)
--  specialisation ∈ {dog, cat, rabbit}
CREATE TABLE Vets (
  id INT PRIMARY KEY,
  name CHAR(20) NOT NULL,
  phonenr INT NOT NULL CHECK (phonenr > 0),
  specialisation TEXT 
  CHECK (specialisation IN ('dog', 'cat', 'rabbit')));

-- Make sure to add enough information to be able to test your solutions!


-- b)
CREATE TABLE Bookings (
  emp INT REFERENCES Vets,
  chipnr INT REFERENCES Pets,
  bdate DATE,
  time INT NOT NULL CHECK (time in (9,10,11,13,14,15)),
  length INT NOT NULL DEFAULT 30 CHECK (length IN (30, 60)),
  PRIMARY KEY (emp,bdate,time),
  UNIQUE (chipnr, bdate, time) );
-- Alternative one could instead have all this, which implies the solution about
-- and it is a bit redundant 
--  PRIMARY KEY (emp,chipnr,bdate,time)
--  UNIQUE (chipnr, bdate, time)
--  UNIQUE (emp, bdate, time)


-- c)
WITH MonthBookings AS
 (SELECT Clients.name AS client, 500*length/30 AS monthfee
  FROM Bookings, Pets, Clients
  WHERE Bookings.chipnr = Pets.chipnr AND Pets.owner = Clients.name
        AND date_part('month', CURRENT_DATE) = date_part('month', bdate)
        AND date_part('year', CURRENT_DATE) = date_part('year', bdate))
SELECT client, SUM(monthfee) AS fee
FROM MonthBookings
GROUP BY client;
