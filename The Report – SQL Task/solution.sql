SELECT
    CASE
        WHEN g.grade >= 8 THEN s.student_Name
        ELSE NULL
    END AS Name,
    g.grade AS Grade,
    s.marks AS Mark
FROM
    dbo.Students s
JOIN dbo.Grades g ON s.marks BETWEEN g.minMark AND g.maxMark
WHERE
    g.grade >= 8
    OR (g.grade < 8 AND s.marks IS NOT NULL)
ORDER BY
    g.grade DESC,
    CASE
        WHEN g.grade >= 8 THEN s.student_Name
        ELSE NULL
    END ASC,
    CASE
        WHEN g.grade < 8 THEN s.marks
    END ASC;
