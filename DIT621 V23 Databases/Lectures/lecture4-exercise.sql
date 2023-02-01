-- psql -v ON_ERROR_STOP=1 -U postgres portal

-- Deletes everything to make this file re-runnable
\set QUIET true
SET client_min_messages TO NOTICE;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false


-- 1.a) 
-- States(_name_, biden, trump, electors)
CREATE TABLE States (
  name TEXT PRIMARY KEY,
  biden INT NOT NULL CHECK (biden >= 0),
  trump INT NOT NULL CHECK (trump >= 0),
  electors INT NOT NULL CHECK (electors >= 0) );

-- Test data
INSERT INTO States VALUES ('NV', 588252,  580605, 6);
INSERT INTO States VALUES ('AZ', 3215969, 3051555, 11);
INSERT INTO States VALUES ('GA', 2406774, 2429783, 16);
INSERT INTO States VALUES ('PA', 3051555, 3215969, 20);
-- Slightly simplified data
INSERT INTO States VALUES ('Red states', 0, 1, 232);
INSERT INTO States VALUES ('Blue states', 1, 0, 253);


-- 1.b) 
CREATE OR REPLACE VIEW StateResults AS
(-- States where Biden won
 SELECT name, 'Biden' AS candidate, electors 
 FROM States 
 WHERE biden > trump)
UNION 
(-- States where Trump won
 SELECT name, 'Trump', electors 
 FROM States 
 WHERE trump > biden);

-- Just checking that it works
SELECT * FROM StateResults;


-- Alternative query using CASE expressions
CREATE OR REPLACE VIEW NewStateResults AS
SELECT name,
      CASE WHEN biden > trump THEN 'Biden' ELSE 'Trump' END AS candidate,
      electors FROM States;


-- 1.c) 
SELECT candidate, SUM(electors) AS total
FROM StateResults
GROUP BY candidate;



