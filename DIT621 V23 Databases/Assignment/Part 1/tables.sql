

CREATE TABLE Students (
    idnr TEXT PRIMARY KEY CHECK (idnr ~ '^[0-9]{10}$'),
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL
);
/*
CREATE TABLE Students (
  idnr TEXT NOT NULL PRIMARY KEY CHECK (idnr LIKE '__________'),
  name TEXT NOT NULL,
  login TEXT NOT NULL,
  program TEXT NOT NULL);
  */
  
  CREATE TABLE Branches (
  name TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY(name, program));
  
  
  CREATE TABLE Courses (
  code TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  credits FLOAT NOT NULL CHECK (credits > 0),
  department TEXT NOT NULL);
  
  
  CREATE TABLE LimitedCourses (
  code TEXT NOT NULL PRIMARY KEY,
  capacity INT NOT NULL CHECK (capacity > 0),
  FOREIGN KEY (code) REFERENCES Courses);
  
  
  CREATE TABLE classifications (
  name TEXT NOT NULL PRIMARY KEY);
  
  
  CREATE TABLE classified (
  course TEXT NOT NULL,
  classification TEXT NOT NULL,
  PRIMARY KEY(course, classification),
  FOREIGN KEY (course) REFERENCES Courses,
  FOREIGN KEY (classification) REFERENCES classifications);
  
  
  
  CREATE TABLE StudentBranches (
  student TEXT NOT NULL PRIMARY KEY CHECK (student LIKE '__________'),
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  FOREIGN KEY (student) REFERENCES Students,
  FOREIGN KEY (branch, program) REFERENCES Branches
  );
  
  
  CREATE TABLE MandatoryProgram (
  course TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY(course, program),
  FOREIGN KEY (course) REFERENCES Courses);
  
  
  CREATE TABLE MandatoryBranch (
  course TEXT NOT NULL,
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY(course, branch, program),
  FOREIGN KEY (course) REFERENCES Courses,
  FOREIGN KEY (branch, program) REFERENCES Branches);
  
  
  CREATE TABLE RecommendedBranch (
  course TEXT NOT NULL,
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY(course, branch, program),
  FOREIGN KEY (course) REFERENCES Courses,
  FOREIGN KEY (branch, program) REFERENCES Branches);
  
  
  CREATE TABLE Registered (
  student TEXT NOT NULL,
  course TEXT NOT NULL,
  PRIMARY KEY(student, course),
  FOREIGN KEY (student) REFERENCES Students,
  FOREIGN KEY (course) REFERENCES courses
  );
  
  
  CREATE TABLE Taken (
  student TEXT NOT NULL,
  course TEXT NOT NULL,
  grade CHAR(1) NOT NULL,
  PRIMARY KEY(student, course),
  FOREIGN KEY (student) REFERENCES Students,
  FOREIGN KEY (course) REFERENCES courses
  );
  
  
  CREATE TABLE WaitingList (
  student TEXT NOT NULL,
  course TEXT NOT NULL,
  position INT NOT NULL,
  PRIMARY KEY(student, course),
  FOREIGN KEY (student) REFERENCES Students,
  FOREIGN KEY (course) REFERENCES LimitedCourses
  );
  
  --test
  
   
  

/*
-- idnr=national identification number (10 digits) 
Students(idnr, name, login, program) 
 
Branches(name, program) 
 
Courses(code, name, credits, department) 
 
LimitedCourses(code, capacity) 
    code → Courses.code 
 
StudentBranches(student, branch, program) 
    student → Students.idnr 
    (branch, program) → Branches.(name, program) 
 
Classifications(name) 
 
Classified(course, classification) 
    course → courses.code 
    classification → Classifications.name 
 
MandatoryProgram(course, program) 
    course → Courses.code 
 
MandatoryBranch(course, branch, program) 
    course → Courses.code 
    (branch, program) → Branches.(name, program) 
 
RecommendedBranch(course, branch, program) 
    course → Courses.code 
    (branch, program) → Branches.(name, program) 
 
Registered(student, course) 
    student → Students.idnr 
    course → Courses.code 
 
Taken(student, course, grade) 
    student → Students.idnr 
    course → Courses.code 
 
-- position is either a SERIAL, a TIMESTAMP or the actual position 
WaitingList(student, course, position) 
    student → Students.idnr 
    course → Limitedcourses.code

	


CREATE TABLE Countries (
  name TEXT PRIMARY KEY,
  abbr CHAR(2) NOT NULL UNIQUE,
  capital TEXT NOT NULL,
  area FLOAT NOT NULL,
  population INT NOT NULL CHECK (population >= 0),
  continent VARCHAR(10) NOT NULL,
  currency CHAR(3),
  CONSTRAINT none_sense CHECK (area > population * 10) );
  
  
  CREATE TABLE CourseGrades (
  student TEXT,
  course CHAR(6),
  grade INT DEFAULT 0,
  CONSTRAINT okgrade CHECK (grade IN (0,3,4,5)),
  PRIMARY KEY (student, course));
  
  
  ALTER TABLE Countries ALTER COLUMN continent TYPE CHAR(2);
  
  
  ALTER TABLE Countries ADD language TEXT;


-- Disallowing empty values
ALTER TABLE Countries ALTER COLUMN language SET NOT NULL;


-- Actually we don't want this column after all!
ALTER TABLE Countries DROP COLUMN language;


-- Check table description




-- Disallowing empty values


-- Removing a constraint
ALTER TABLE Countries DROP CONSTRAINT none_sense;


-- Check table description
DROP TABLE CourseGrades;

-- Deleting a table that doesn't exists will not work
--DROP TABLE Contacts;
-- This will work
DROP TABLE IF EXISTS Contacts;

*/



/*
INSERT INTO Countries
VALUES ('Denmark', 'DK', 'Copenhagen', 43094, 5484000, 'EU', 'DKK');
INSERT INTO Countries
VALUES ('Sweden', 'SE', '' , -449964, 9555893, 'EU', NULL);


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

SELECT * FROM Countries;


CREATE TABLE Teachers (
  idnr TEXT PRIMARY KEY
  CHECK (idnr LIKE '______-____'),
  name TEXT
  CHECK (name LIKE '% %'),
  phone TEXT NOT NULL,
  CHECK (phone SIMILAR TO '[0-9]{10}') );
  
  INSERT INTO Teachers VALUES ('123456-7890', 'Ana Bove', '0123456789'); 
  
  SELECT *
FROM (SELECT name, CEIL(population/area) AS density
      FROM Countries) AS Densities
ORDER BY density DESC
LIMIT 5;

CREATE OR REPLACE VIEW Densities AS
  (SELECT name, ROUND(population/area) AS density, abbr FROM Countries);
  
  SELECT name FROM Densities
ORDER BY density DESC
LIMIT 3;

SELECT name, abbr FROM Densities
ORDER BY density ASC
LIMIT 3;

CREATE MATERIALIZED VIEW MDensities AS
  (SELECT name, ROUND(population/area) AS density FROM Countries);

SELECT * FROM MDensities;

INSERT INTO Countries
VALUES ('Salvador', 'SA', 'Salvador', 134567, 7000000, 'AM', 'SAP');

SELECT * FROM MDensities;

REFRESH MATERIALIZED VIEW MDensities;

SELECT * FROM MDensities;

--any select can be converted to Mview view

CREATE MATERIALIZED VIEW TDensities AS
SELECT currency FROM Countries WHERE continent = 'AM'
UNION 
SELECT currency FROM Countries WHERE continent = 'EU';

SELECT currency FROM Countries WHERE continent IN ('AM', 'EU');

DROP MATERIALIZED VIEW MDensities;

DROP MATERIALIZED VIEW TDensities;

DROP VIEW Densities;

SELECT MAX(population) AS max_min_pop FROM Countries
UNION
SELECT MIN(population) AS max_min_pop FROM Countries;


SELECT name, 'small' AS size FROM Countries WHERE area < 300000
UNION
SELECT name, 'big' AS size FROM Countries WHERE area >= 300000;

INSERT INTO Countries
VALUES ('NewSalvador', 'NS', 'Salvador', 134567, 10000000, 'AM', 'SAP');
INSERT INTO Countries
VALUES ('NewSweden', 'SN', 'Sweden', 453627, 17352648, 'EU', 'NSK');

SELECT * FROM Countries;

SELECT name AS place FROM Countries
INTERSECT
SELECT capital AS place FROM Countries;

SELECT currency FROM Countries
EXCEPT 
SELECT currency FROM Countries WHERE currency != 'EUR';

WITH
  ManyPeople AS
    (SELECT name, area, 'many' AS size FROM Countries
     WHERE population >= 10000000),
  FewPeople AS
    (SELECT name, area, 'few' AS size FROM Countries
     WHERE population < 6000000)
(-- Removes American countries from FewPeople
 SELECT name, size FROM FewPeople
 EXCEPT
 SELECT name, 'few' FROM Countries WHERE continent = 'AM')
UNION  -- puts the results together 
(-- Keeps countries with big area from ManyPeople
 SELECT name, size FROM ManyPeople
 INTERSECT
 SELECT name, 'many' FROM Countries WHERE area > 2500000);
 
 CREATE TABLE Currencies(
  code CHAR(3) PRIMARY KEY,
  name TEXT,
  value FLOAT);
  
  INSERT INTO Currencies VALUES ('SEK','Swedish Krona', 1.00);
INSERT INTO Currencies VALUES ('DKK','Danish Krone', 1.36);
INSERT INTO Currencies VALUES ('EUR','Euro', 10.17);
INSERT INTO Currencies VALUES ('ARS','Peso Argentino', 0.1);
INSERT INTO Currencies VALUES ('UYU','Peso Uruguayo', 0.2);
INSERT INTO Currencies VALUES ('USD','Dollar', 8.28);
INSERT INTO Currencies VALUES ('BTC','Bitcoin', 85634.34);

SELECT DISTINCT currency AS code
FROM Countries
WHERE currency NOT IN (SELECT code FROM Currencies);

SELECT Countries.name, code, Currencies.name, value
FROM Countries, Currencies;

SELECT Countries.name, code, Currencies.name, value
FROM Countries, Currencies
WHERE currency = code;

SELECT Co.name AS country, code, Cu.name As currency, value
FROM Countries AS Co, Currencies AS Cu
WHERE currency = code;

SELECT DISTINCT currency AS code
FROM Countries
WHERE currency NOT IN (SELECT code FROM Currencies);

SELECT * FROM Countries;

INSERT INTO Currencies 
   (SELECT DISTINCT currency AS code
    FROM Countries
    WHERE currency NOT IN (SELECT code FROM Currencies) );

UPDATE Currencies
SET name = 'Norwegian Krone', value =  0.96
WHERE code = 'NOK';


ALTER TABLE Countries
ADD FOREIGN KEY (currency) REFERENCES Currencies (code);

SELECT * FROM Countries;

CREATE TABLE Cities (
  name TEXT,
  country TEXT,
  PRIMARY KEY (name, country) );

CREATE TABLE CountryCapitals (
  name TEXT PRIMARY KEY,
  capital TEXT,
  FOREIGN KEY (capital, name) REFERENCES Cities );
  */	


