

CREATE TABLE Programs (
	name TEXT PRIMARY KEY,
	abbr TEXT NOT NULL
  );

CREATE TABLE Departments (
	name TEXT PRIMARY KEY,
	abbr TEXT NOT NULL,
	UNIQUE(abbr)
  );
  
  
  
CREATE TABLE Students (
    idnr TEXT PRIMARY KEY CHECK (idnr ~ '^[0-9]{10}$'),
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL,
    UNIQUE(idnr,program),
    UNIQUE(login),
    FOREIGN KEY(program) REFERENCES Programs
);


CREATE TABLE Branches (
  name TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY(name, program),
  FOREIGN KEY (program) REFERENCES Programs
  );

CREATE TABLE Courses (
  code CHAR(6) NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  credits FLOAT NOT NULL CHECK (credits > 0),
  department TEXT NOT NULL,
  FOREIGN KEY (department) REFERENCES Departments ON UPDATE CASCADE
  );
  
  
  
  
  CREATE TABLE Prerequisites (
	code TEXT,
	reqCourse TEXT NOT NULL,
	PRIMARY KEY(code, reqCourse),
	FOREIGN KEY (reqCourse) REFERENCES Courses
  );
  
  
  
  

CREATE TABLE LimitedCourses (
  code TEXT NOT NULL PRIMARY KEY,
  capacity INT NOT NULL CHECK (capacity > 0),
  FOREIGN KEY (code) REFERENCES Courses
  );
  
  
CREATE TABLE Classifications (
  name TEXT PRIMARY KEY
  );
  
CREATE TABLE Classified (
  course CHAR(6) NOT NULL,
  classification TEXT NOT NULL,
  PRIMARY KEY(course, classification),
  FOREIGN KEY (course) REFERENCES Courses,
  FOREIGN KEY (classification) REFERENCES classifications ON UPDATE CASCADE
  );
  

CREATE TABLE StudentBranches (
  student TEXT NOT NULL PRIMARY KEY CHECK (student ~ '^[0-9]{10}$'),
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  FOREIGN KEY (student, program) REFERENCES Students(idnr, program),
  FOREIGN KEY (branch, program) REFERENCES Branches ON UPDATE CASCADE
  );
  
  
CREATE TABLE MandatoryProgram (
  course CHAR(6),
  program TEXT NOT NULL,
  PRIMARY KEY(course, program),
  FOREIGN KEY (course) REFERENCES Courses,
  FOREIGN KEY (program) REFERENCES Programs
  );
  
  
CREATE TABLE MandatoryBranch (
  course CHAR(6) NOT NULL,
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY(course, branch, program),
  FOREIGN KEY (course) REFERENCES Courses,
  FOREIGN KEY (branch, program) REFERENCES Branches
  );
  
  
CREATE TABLE RecommendedBranch (
  course CHAR(6) NOT NULL,
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY(course, branch, program),
  FOREIGN KEY (course) REFERENCES Courses,
  FOREIGN KEY (branch, program) REFERENCES Branches
  );
  
  
CREATE TABLE Registered (
  student TEXT CHECK (student ~ '^[0-9]{10}$'),
  course CHAR(6) NOT NULL,
  PRIMARY KEY(student, course),
  FOREIGN KEY (student) REFERENCES Students,
  FOREIGN KEY (course) REFERENCES courses
  );
  
  
CREATE TABLE Taken (
  student TEXT CHECK (student ~ '^[0-9]{10}$'),
  course CHAR(6) NOT NULL,
  grade CHAR(1) CHECK (grade = 'U' OR grade = '3' OR grade = '4' OR grade = '5'),
  PRIMARY KEY(student, course),
  FOREIGN KEY (student) REFERENCES Students,
  FOREIGN KEY (course) REFERENCES Courses
  );
  
  
CREATE TABLE WaitingList (
  student TEXT CHECK (student ~ '^[0-9]{10}$'),
  course CHAR(6) NOT NULL,
  position SERIAL NOT NULL,
  PRIMARY KEY(student, course),
  FOREIGN KEY (student) REFERENCES Students,
  FOREIGN KEY (course) REFERENCES LimitedCourses
  );

