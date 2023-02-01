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


---------------------- Functions ------------------------

-- Tables
CREATE TABLE Students (
  id CHAR(10) PRIMARY KEY,
  cid CHAR(6) UNIQUE,
  name TEXT NOT NULL,
  phone INT CHECK (phone > 0) );

CREATE TABLE Courses (
  code CHAR(6) PRIMARY KEY,
  name TEXT NOT NULL,
  points FLOAT DEFAULT 7.5 CHECK (points IN (7.5, 15, 30)) );
  
CREATE TABLE CourseRegistrations (
  student CHAR(10) REFERENCES Students ON DELETE CASCADE ON UPDATE CASCADE,
  course CHAR(6) REFERENCES Courses ON DELETE CASCADE ON UPDATE CASCADE,
  position INT CHECK (position > 0),
  PRIMARY KEY (student, course) );

-- Values
INSERT INTO Students VALUES ('1234567890', 'stunr1', 'Student Uno', 123456);
INSERT INTO Students VALUES ('2345678901', 'stunr2', 'Student Dos', 234561);
INSERT INTO Courses VALUES ('TDA357', 'Databases');
INSERT INTO Courses VALUES ('TMV028', 'Automata');


-- SQL Function
CREATE OR REPLACE FUNCTION nextPos (CHAR(6)) RETURNS INT AS $$
  SELECT COUNT(*) + 1 FROM CourseRegistrations WHERE course = $1
$$ LANGUAGE SQL;

-- Uses
SELECT * FROM CourseRegistrations;

SELECT nextPos ('TDA357') AS NextPosition;

INSERT INTO CourseRegistrations
VALUES ('1234567890', 'TDA357', nextPos('TDA357'));

INSERT INTO CourseRegistrations
VALUES ('2345678901', 'TDA357', nextPos('TDA357'));

INSERT INTO CourseRegistrations
VALUES ('2345678901', 'TMV028', nextPos('TMV028'));

SELECT * FROM CourseRegistrations;

-- Which is the next position in the courses
SELECT code, name, nextPos (code) FROM Courses;

SELECT DISTINCT course, nextPos (course) FROM CourseRegistrations;


-- An alternative definition that would use plpgsql instead of SQL
CREATE OR REPLACE FUNCTION nextPos (CHAR(6)) RETURNS INT AS $$
DECLARE
  pos INT;
BEGIN
  pos := (SELECT COUNT(*) FROM CourseRegistrations WHERE course = $1);
  RETURN (pos+1);
END
$$ LANGUAGE plpgsql;

-- Used in the same way
INSERT INTO CourseRegistrations
VALUES ('1234567890', 'TMV028', nextPos ('TMV028'));

SELECT DISTINCT course, nextPos (course) FROM CourseRegistrations;


---------------------- Triggers ------------------------

-- Tables
CREATE TABLE Accounts (
  id CHAR(6) PRIMARY KEY,
  name TEXT NOT NULL,
  balance INT CHECK (balance >= 0) );

CREATE TABLE Transfers (
  sender TEXT REFERENCES Accounts ON DELETE CASCADE ON UPDATE CASCADE,
  receiver TEXT REFERENCES Accounts ON DELETE CASCADE ON UPDATE CASCADE,
  amount INT CHECK (amount > 0),
  CHECK (receiver != sender) );

-- Inserts in accounts
INSERT INTO Accounts VALUES ('123456', 'Ana', 10000);
INSERT INTO Accounts VALUES ('234567', 'Peter', 20000);
INSERT INTO Accounts VALUES ('345678', 'Jan', 5000);

SELECT * FROM Accounts;


-- Update balance of account when a new transfer is added 
CREATE OR REPLACE FUNCTION make_transfer() RETURNS TRIGGER AS $$
BEGIN
 UPDATE Accounts SET balance = balance - NEW.amount WHERE id=NEW.sender;
 UPDATE Accounts SET balance = balance + NEW.amount WHERE id=NEW.receiver;
 RETURN NEW;      -- could have been RETURN NULL
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS  after_insert_on_transfer ON Transfers;

CREATE TRIGGER after_insert_on_transfer
  AFTER INSERT ON Transfers
  FOR EACH ROW
  EXECUTE FUNCTION make_transfer();


-- Some transferences
INSERT INTO Transfers VALUES ('123456', '234567', 200);
INSERT INTO Transfers VALUES ('123456', '345678', 2000);
SELECT * FROM Accounts;
SELECT * FROM Transfers;


-- This transfer would break the balance constraint in Accounts
-- This is caught during the trigger execution and nothing changes
INSERT INTO Transfers VALUES ('345678', '234567', 20000);
SELECT * FROM Accounts;
SELECT * FROM Transfers;


-- Make sure there is enough money in the bank
CREATE OR REPLACE FUNCTION checkMinimumTotalBalance() RETURNS TRIGGER AS $$
DECLARE
  total INT;
BEGIN
  total := (SELECT SUM(balance) FROM Accounts);
  IF total < 30000 THEN
    RAISE EXCEPTION 'error: the total balance would be %, which is too low', total;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS minimumBankBalance ON Accounts;

CREATE TRIGGER minimumBankBalance
  AFTER UPDATE OR DELETE ON Accounts
  FOR EACH STATEMENT
  EXECUTE FUNCTION checkMinimumTotalBalance();


-- Some updates in Accounts
UPDATE Accounts SET balance = 5000 WHERE id='345678';
SELECT * FROM Accounts;

-- The trigger will prevent this update
UPDATE Accounts SET balance = 5000 WHERE id='234567';
SELECT * FROM Accounts;


---------------------- Another example ------------------------

-- Table
CREATE TABLE WaitingList (
  name TEXT,
  pos INT PRIMARY KEY);


-- A function that computes the next available position
CREATE FUNCTION next() RETURNS INT AS $$
  SELECT COALESCE(MAX(pos),0)+1 FROM WaitingList
$$ LANGUAGE SQL;

-- Use the next available position as the default value
ALTER TABLE WaitingList ALTER pos SET DEFAULT next();


-- Some insertions
INSERT INTO WaitingList VALUES ('Ana');
INSERT INTO WaitingList VALUES ('Peter');
INSERT INTO WaitingList VALUES ('Sofia');
INSERT INTO WaitingList VALUES ('John');

SELECT * FROM WaitingList;


-- A function to adjust positions after someone is removed from the list
CREATE OR REPLACE FUNCTION compact() RETURNS TRIGGER AS $$
BEGIN
  UPDATE WaitingList SET pos = pos-1 WHERE pos>=OLD.pos;
  RETURN NULL;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS compact ON WaitingList;

-- A trigger to adjust positions after deletes
-- Will not work if we set BEFORE!
CREATE TRIGGER compact
  AFTER DELETE ON WaitingList
  FOR EACH ROW 
  EXECUTE FUNCTION compact();

-- Testing
DELETE FROM WaitingList WHERE name = 'Peter';

SELECT * FROM WaitingList;


---------------------- Example: Constraints, Views, Triggers (I) ---------------

CREATE TABLE Registrations (
  student TEXT,
  course TEXT,
  PRIMARY KEY (student, course));

CREATE TABLE Assignments (
  course TEXT,
  name TEXT,
  description TEXT,
  deadline TIMESTAMP,
  PRIMARY KEY (course, name));

CREATE TABLE Submissions (
  idnr INT PRIMARY KEY,		-- Could be a SERIAL
  student TEXT,
  course TEXT,
  assignment TEXT,
  stime INT,
  FOREIGN KEY (course, assignment) REFERENCES Assignments,
  FOREIGN KEY (student, course) REFERENCES Registrations,
  UNIQUE(student, assignment, stime));

CREATE TABLE SubmittedFileTables (
  submission INT,
  filename TEXT,
  contents TEXT,
  FOREIGN KEY (submission) REFERENCES Submissions ON DELETE CASCADE,
  PRIMARY KEY (submission, filename));

CREATE VIEW SubmittedFile AS
  SELECT *, length (contents) AS filesize
  FROM SubmittedFileTables;

-- Triggers need to be implemented! :)
