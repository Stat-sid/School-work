


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
(SELECT basicInformation.idnr AS student, mp.course
FROM MandatoryProgram AS mp
natural JOIN basicInformation
UNION
SELECT basicInformation.idnr AS student, mb.course 
FROM MandatoryBranch AS mb
natural join basicInformation)
EXCEPT
SELECT p.student AS student, p.course
FROM passedCourses AS p, courses AS c;



CREATE VIEW PathToGraduation AS
WITH calculations AS (SELECT basicInformation.idnr AS student,
        --    SUM(credits) AS totalCredits 
           COALESCE(SUM(DISTINCT passedCourses.credits), 0) AS totalCredits,
           COUNT(DISTINCT UnreadMandatory.course) AS mandatoryLeft,
           SUM(DISTINCT CASE WHEN Classified.classification = 'math' THEN passedCourses.credits ELSE 0 END) AS mathCredits,
           SUM(DISTINCT CASE WHEN Classified.classification = 'research' THEN passedCourses.credits ELSE 0 END) AS researchCredits,
           COUNT(DISTINCT CASE WHEN Classified.classification = 'seminar' THEN PassedCourses.course ELSE NULL END) AS seminarCourses
    FROM basicInformation
    LEFT JOIN PassedCourses ON PassedCourses.student = basicInformation.idnr
    LEFT JOIN Classified ON passedCourses.course = Classified.course
    LEFT JOIN UnreadMandatory ON basicInformation.idnr = UnreadMandatory.student
    GROUP BY basicInformation.idnr),
	calc AS (
SELECT StudentBranches.student as student, SUM(COALESCE(PassedCourses.credits,0)) as reccredits
			FROM StudentBranches
			LEFT JOIN RecommendedBranch ON (StudentBranches.branch, StudentBranches.program) = (RecommendedBranch.branch, RecommendedBranch.program)
			LEFT JOIN  PassedCourses ON (StudentBranches.student, RecommendedBranch.course) = (PassedCourses.student, PassedCourses.course)	
		GROUP BY StudentBranches.student
	)
    SELECT calculations.student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses,
	COALESCE((recCredits >= 10 AND mandatoryLeft = 0 AND mathCredits >= 20 AND researchCredits >= 10 AND seminarCourses >= 1),FALSE) AS qualified
	From calculations 
	LEFT JOIN calc
	ON calculations.student = calc.student;
