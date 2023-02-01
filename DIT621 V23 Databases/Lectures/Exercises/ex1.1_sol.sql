-- psql -v ON_ERROR_STOP=1 -U postgres portal

-- Deletes everything to make this file re-runnable
\set QUIET true
SET client_min_messages TO NOTICE;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false


-- a) Tables
-- Periods(_pname_, started, ended)
CREATE TABLE Periods(
  pname TEXT PRIMARY KEY,
  started INT NOT NULL,
  ended INT NOT NULL,
  CHECK (started <= ended) );

-- Events(_ename_, year)
CREATE TABLE Events(
  ename TEXT PRIMARY KEY,
  year INT NOT NULL );  

-- Test data
INSERT INTO Periods VALUES ('P1', 1950, 2050);
INSERT INTO Periods VALUES ('P2', 1975, 2150);
INSERT INTO Periods VALUES ('P3', 1920, 1975);

INSERT INTO Events VALUES ('E1', 1925); -- In P3 only
INSERT INTO Events VALUES ('E2', 2150); -- In P2 only
INSERT INTO Events VALUES ('E3', 1975); -- In P1, P2 and P3
INSERT INTO Events VALUES ('The GCHD', 2000); -- In P1 and P2
--                         ^ shortened the name down a bit :)


-- An auxliary view
CREATE VIEW EventPeriods AS 
SELECT * 
FROM Periods, Events
WHERE started <= year AND year <= ended;

SELECT *
FROM EventPeriods
ORDER BY pname, ename;


-- b)
WITH InPeriods AS
  (SELECT *
   FROM EventPeriods
   WHERE ename = 'The GCHD')
SELECT DISTINCT ename
FROM EventPeriods
WHERE pname IN (SELECT pname FROM InPeriods);

-- Alternative
WITH InPeriods AS
  (SELECT pname
   FROM EventPeriods
   WHERE ename = 'The GCHD')
SELECT DISTINCT ename
FROM EventPeriods JOIN InPeriods USING (pname);


-- c)
WITH EventCount AS
  (SELECT pname, COUNT(*) AS nrEvents
   FROM EventPeriods
   GROUP BY pname)
SELECT *
FROM EventCount
WHERE nrEvents = (SELECT MAX(nrEvents) FROM EventCount);

-- This alternative is not good since it will only work if there is only
-- one period with the highest nr of events!
WITH EventCount AS
  (SELECT pname, COUNT(*) AS nrEvents
   FROM EventPeriods
   GROUP BY pname)
SELECT *
FROM EventCount
ORDER BY nrEvents DESC
LIMIT 1;
