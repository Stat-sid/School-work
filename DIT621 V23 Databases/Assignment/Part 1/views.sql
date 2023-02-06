


CREATE VIEW BasicInformation AS
    SELECT Students.idnr, Students.name, Students.login, Students.program, COALESCE (StudentBranches.branch, NULL) AS branch
    FROM Students LEFT JOIN StudentBranches ON Students.idnr = StudentBranches.student;



CREATE VIEW FinishedCourses AS
SELECT t.course, t.student, t.grade, c.credits
FROM taken AS t, courses AS c WHERE code = course ; 



CREATE VIEW PassedCourses AS
    SELECT FinishedCourses.student, FinishedCourses.course, FinishedCourses.credits
    FROM FinishedCourses
    WHERE FinishedCourses.grade != 'U';



CREATE VIEW Registrations AS
SELECT r.student, r.course, 'registered' AS status  
FROM registered AS r
UNION
SELECT w.student, w.course, 'waiting' AS status 
FROM waitingList AS w; 


CREATE VIEW UnreadMandatory AS
(SELECT s.idnr AS student, mp.course
FROM MandatoryProgram AS mp, Students AS s WHERE s.program = mp.program 
UNION
SELECT s.idnr AS student, mb.course
FROM MandatoryBranch AS mb, Students AS s)
EXCEPT
SELECT DISTINCT p.student, p.course
FROM passedCourses AS p, courses AS c;

DROP VIEW UnreadMandatory CASCADE;


CREATE VIEW PathToGraduation AS
WITH calculations AS (SELECT Students.idnr AS student,
           COALESCE(SUM(DISTINCT Courses.credits), 0) AS totalCredits,
           COUNT(DISTINCT UnreadMandatory.course) AS mandatoryLeft,
           SUM(DISTINCT CASE WHEN Classified.classification = 'math' THEN Courses.credits ELSE 0 END) AS mathCredits,
           SUM(DISTINCT CASE WHEN Classified.classification = 'research' THEN Courses.credits ELSE 0 END) AS researchCredits,
           COUNT(DISTINCT CASE WHEN Classified.classification = 'seminar' THEN PassedCourses.course ELSE NULL END) AS seminarCourses
    FROM Students
    FULL OUTER JOIN PassedCourses ON Students.idnr = PassedCourses.student
    left OUTER JOIN Courses ON PassedCourses.course = Courses.code
    LEFT JOIN Classified ON Courses.code = Classified.course
    LEFT JOIN UnreadMandatory ON Students.idnr = UnreadMandatory.student
    GROUP BY Students.idnr),
	calc AS (SELECT SUM(DISTINCT Courses.credits) AS recCredits
	FROM Students
	FULL OUTER JOIN PassedCourses ON Students.idnr = PassedCourses.student
	left OUTER JOIN recommendedBranch ON PassedCourses.course = recommendedBranch.course
	left OUTER JOIN Courses ON PassedCourses.course = Courses.code And recommendedBranch.course = Courses.code
	)
    SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses,
	(recCredits >= 10 AND mandatoryLeft = 0 AND mathCredits >= 20 AND researchCredits >= 10 AND seminarCourses >= 1) AS qualified
	From calculations, calc;
