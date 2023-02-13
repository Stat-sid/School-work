-- WITH    
--     total_credits AS(
--         SELECT student, SUM(credits) AS totalCredits FROM PassedCourses GROUP BY student
--     ),
--     course_categories AS(
--         SELECT Students.idnr AS student,
--         COUNT(DISTINCT UnreadMandatory.course) AS mandatoryLeft,
--         SUM(DISTINCT CASE WHEN Classified.classification = 'math' THEN Courses.credits ELSE 0 END) AS mathCredits,
--         SUM(DISTINCT CASE WHEN Classified.classification = 'research' THEN Courses.credits ELSE 0 END) AS researchCredits,
--         COUNT(DISTINCT CASE WHEN Classified.classification = 'seminar' THEN PassedCourses.course ELSE NULL END) AS seminarCourses
--     FROM Students
--     FULL OUTER JOIN PassedCourses ON Students.idnr = PassedCourses.student
--     LEFT OUTER JOIN Courses ON PassedCourses.course = Courses.code
--     LEFT JOIN Classified ON Courses.code = Classified.course
--     LEFT JOIN UnreadMandatory ON Students.idnr = UnreadMandatory.student
--     GROUP BY Students.idnr
--     ),
--     calc AS (
--         SELECT SUM(DISTINCT Courses.credits) AS recCredits
-- 	FROM Students
-- 	FULL OUTER JOIN PassedCourses ON Students.idnr = PassedCourses.student
-- 	left OUTER JOIN recommendedBranch ON PassedCourses.course = recommendedBranch.course
-- 	left OUTER JOIN Courses ON PassedCourses.course = Courses.code And recommendedBranch.course = Courses.code
-- 	)
--     SELECT course_categories.student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses,
-- 	(recCredits >= 10 AND mandatoryLeft = 0 AND mathCredits >= 20 AND researchCredits >= 10 AND seminarCourses >= 1) AS qualified
-- 	FROM total_credits, course_categories, calc;



    -- ML AS(
    --     SELECT student, COUNT(*) AS mandatoryLeft FROM Unreadmandatory WHERE course IS NOT NULL GROUP BY student
    -- ),
    -- Math AS(
    --     SELECT student, SUM(PassedCourses.credits) AS mathCredits FROM PassedCourses, Classified
    --     WHERE PassedCourses.course = Classified.course AND Classified.classification = 'math'  GROUP BY PassedCourses.student
    -- ),
    -- Res AS(
    --     SELECT student, SUM(PassedCourses.credits) AS researchCredits FROM PassedCourses, Classified
    --     WHERE PassedCourses.course = Classified.course AND Classified.classification = 'research'  GROUP BY PassedCourses.student
    -- ),
    -- Seminar AS(
    --     SELECT student, COUNT(*) AS seminarCourses FROM Passedcourses, Classified
    --     WHERE Passedcourses.course = Classified.course AND Classified.classification = 'seminar'  GROUP BY Passedcourses.student
    -- ),
    -- PR AS(
    --     SELECT StudentBranches.student as student, COALESCE(PassedCourses.credits,0) as credits
    --     FROM StudentBranches
    --     LEFT JOIN RecommendedBranch ON (StudentBranches.branch, StudentBranches.program) = (RecommendedBranch.branch, RecommendedBranch.program)
    --     LEFT JOIN  PassedCourses ON (StudentBranches.student, RecommendedBranch.course) = (PassedCourses.student, PassedCourses.course)
    -- ),
    -- CREC AS(
    --     SELECT PR.student, COALESCE(SUM(PR.credits),0) as recommendedCredits 
    --     FROM PR 
    --     GROUP BY PR.student
    -- ), 
    -- CR AS(
    --     SELECT Students.idnr AS student, branch, COALESCE(totalCredits, 0) AS totalCredits, COALESCE(mandatoryLeft, 0) AS mandatoryLeft, COALESCE(mathCredits, 0) AS mathCredits, COALESCE(researchCredits, 0) AS researchCredits, COALESCE(seminarCourses, 0) AS seminarCourses, COALESCE(recommendedCredits, 0) as recommendedCredits   
    --     FROM Students
	-- 		LEFT JOIN total_credits ON Students.idnr = total_credits.student
	-- 		LEFT JOIN ML ON Students.idnr = ML.student
	-- 		LEFT JOIN Math ON Students.idnr = Math.student
	-- 		LEFT JOIN Res ON Students.idnr = Res.student
	-- 		LEFT JOIN Seminar ON Students.idnr = Seminar.student
	-- 		LEFT JOIN CREC ON Students.idnr = CREC.student
	-- 		LEFT JOIN Studentbranches ON Students.idnr = Studentbranches.student
	-- 	)
	-- 	SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, COALESCE((
	-- 		mandatoryLeft = 0 
	-- 		AND recommendedCredits >= 10
	-- 		AND mathCredits >= 20
	-- 		AND researchCredits >= 10
	-- 		AND seminarCourses >= 1
	-- 		AND branch IS NOT NULL 
	-- 	), TRUE) as qualified
	-- 	FROM CR;



WITH calculations AS (SELECT basicInformation.idnr AS student,
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
    SELECT calculations.student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, reccredits,
	COALESCE((recCredits >= 10 AND mandatoryLeft = 0 AND mathCredits >= 20 AND researchCredits >= 10 AND seminarCourses >= 1),FALSE) AS qualified
	From calculations 
	LEFT JOIN calc
	ON calculations.student = calc.student;