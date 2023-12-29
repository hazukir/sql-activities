

DROP TABLE IF EXISTS dbo.Students;
GO

CREATE TABLE dbo.Students (
	student_ID INT,
	student_Name VARCHAR(25),
	marks INT
)
GO

DROP TABLE IF EXISTS dbo.Grades;
GO

CREATE TABLE dbo.Grades (
	grade INT,
	minMark INT,
	maxMark INT
)
GO