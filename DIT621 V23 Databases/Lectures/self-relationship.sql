-- psql -v ON_ERROR_STOP=1 -U postgres portal

-- Deletes everything to make this file re-runnable
\set QUIET true
SET client_min_messages TO NOTICE;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false

/*
This implements a many-to-exactly-one self-relationship.
In this case each employee needs to have exactly one boss.
That is, the boss cannot be empty!
*/

-- Employees (_id_, name, boss)
--   boss → Employees
CREATE TABLE Employees (
  id INT Primary KEY,
  name TEXT NOT NULL,
  boss INT NOT NULL REFERENCES Employees );

-- The boss the very first employee can only be oneself!!!
INSERT INTO Employees VALUES (1, 'Ana', 1);
INSERT INTO Employees VALUES (2, 'Peter', 1);
INSERT INTO Employees VALUES (3, 'David', 2);

UPDATE Employees
SET boss = 3
WHERE id = 1;

-- Alternative definition of the table
CREATE TABLE NEmployees (
  id INT Primary KEY,
  name TEXT NOT NULL,
  boss INT NOT NULL,
  FOREIGN KEY (boss) REFERENCES NEmployees );


-- If boss is not null, we can never have the constraint that one cannot be its own boss
-- Otherwise we will never be able to enter a value in the table!
CREATE TABLE BadEmployees (
  id INT Primary KEY,
  name TEXT NOT NULL,
  boss INT NOT NULL REFERENCES Employees,
  CHECK (id != boss) );

-- These insert will fail
--INSERT INTO BadEmployees VALUES (1, 'Ana', 1);
--INSERT INTO BadEmployees VALUES (1, 'Ana', NULL);


/*
This implements a many-to-at-most-one self-relationship with the NULL approach.
In this case each employee might not have a boss.
That is, the boss can be empty!
Which means that we can now have the constraint that one cannot be its own boss!
*/

-- NewEmployees (_id_, name, boss (or NULL))
--   boss → NewEmployees
CREATE TABLE NewEmployees (
  id INT Primary KEY,
  name TEXT NOT NULL,
  boss INT REFERENCES Employees,
  CHECK (id != boss) );

INSERT INTO NewEmployees VALUES (1, 'Ana', NULL);
INSERT INTO NewEmployees VALUES (2, 'Peter', 1);
INSERT INTO NewEmployees VALUES (3, 'David', 2);
-- This is not allowed now
--INSERT INTO NewEmployees VALUES (4, 'Clara', 4);

UPDATE NewEmployees
SET boss = 3
WHERE id = 1;
