-- ============================================================
-- SQL COMMANDS - AI CAREER NAVIGATOR
-- ============================================================
-- Step-by-step SQL commands for manual database creation
-- ============================================================

-- ============================================================
-- STEP 1: CREATE DATABASE (SQLite automatic)
-- ============================================================
-- SQLite-ல database create பண்ண:
-- Command line: sqlite3 students.db
-- This will create students.db file
-- ============================================================


-- ============================================================
-- STEP 2: CREATE TABLES
-- ============================================================

-- TABLE 1: Students
CREATE TABLE students (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    department TEXT NOT NULL,
    year INTEGER NOT NULL,
    cgpa REAL NOT NULL,
    interests TEXT,
    skills TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- TABLE 2: Recommendations
CREATE TABLE recommendations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    career TEXT NOT NULL,
    score INTEGER NOT NULL,
    confidence REAL,
    salary TEXT,
    growth TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id)
);

-- TABLE 3: Feedback
CREATE TABLE feedback (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    career TEXT NOT NULL,
    score INTEGER,
    rating INTEGER,
    helpful INTEGER,
    comments TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id)
);


-- ============================================================
-- STEP 3: INSERT SAMPLE DATA
-- ============================================================

-- Insert Student 1
INSERT INTO students (name, department, year, cgpa, interests, skills)
VALUES ('Rahul Kumar', 'Computer Science', 3, 8.5, 'AI, coding, web dev', 'Python, Java, React');

-- Insert Student 2
INSERT INTO students (name, department, year, cgpa, interests, skills)
VALUES ('Priya Singh', 'Mechanical', 2, 7.8, 'design, CAD', 'AutoCAD, SolidWorks');

-- Insert Student 3
INSERT INTO students (name, department, year, cgpa, interests, skills)
VALUES ('Karthik Raj', 'Civil', 4, 9.0, 'construction, structures', 'STAAD Pro, Revit');


-- ============================================================
-- STEP 4: INSERT RECOMMENDATIONS
-- ============================================================

-- Recommendations for Student 1 (CS)
INSERT INTO recommendations (student_id, career, score, confidence, salary, growth)
VALUES (1, 'Data Scientist', 92, 0.92, '8-15 LPA', 'Very High');

INSERT INTO recommendations (student_id, career, score, confidence, salary, growth)
VALUES (1, 'Full Stack Developer', 88, 0.88, '6-12 LPA', 'High');

INSERT INTO recommendations (student_id, career, score, confidence, salary, growth)
VALUES (1, 'ML Engineer', 85, 0.85, '10-18 LPA', 'Very High');

-- Recommendations for Student 2 (Mechanical)
INSERT INTO recommendations (student_id, career, score, confidence, salary, growth)
VALUES (2, 'Mechanical Design Engineer', 90, 0.90, '4-8 LPA', 'Moderate');

INSERT INTO recommendations (student_id, career, score, confidence, salary, growth)
VALUES (2, 'Automobile Engineer', 86, 0.86, '5-10 LPA', 'High');

-- Recommendations for Student 3 (Civil)
INSERT INTO recommendations (student_id, career, score, confidence, salary, growth)
VALUES (3, 'Structural Engineer', 95, 0.95, '4-9 LPA', 'Moderate');

INSERT INTO recommendations (student_id, career, score, confidence, salary, growth)
VALUES (3, 'Project Manager', 91, 0.91, '5-12 LPA', 'High');


-- ============================================================
-- STEP 5: BASIC SELECT QUERIES
-- ============================================================

-- View all students
SELECT * FROM students;

-- View all recommendations
SELECT * FROM recommendations;

-- View specific student's data
SELECT * FROM students WHERE id = 1;

-- View recommendations for a student
SELECT * FROM recommendations WHERE student_id = 1;


-- ============================================================
-- STEP 6: USEFUL QUERIES
-- ============================================================

-- Query 1: Get student with their recommendations
SELECT 
    s.name, 
    s.department, 
    s.cgpa,
    r.career,
    r.score,
    r.salary
FROM students s
JOIN recommendations r ON s.id = r.student_id
WHERE s.id = 1;


-- Query 2: Top 5 career recommendations across all students
SELECT 
    career, 
    COUNT(*) as times_recommended,
    AVG(score) as avg_score
FROM recommendations
GROUP BY career
ORDER BY times_recommended DESC
LIMIT 5;


-- Query 3: Students by department
SELECT 
    department,
    COUNT(*) as student_count,
    AVG(cgpa) as avg_cgpa
FROM students
GROUP BY department;


-- Query 4: High performers (CGPA > 8.0)
SELECT 
    name,
    department,
    cgpa,
    year
FROM students
WHERE cgpa > 8.0
ORDER BY cgpa DESC;


-- Query 5: Best matching careers (score > 85)
SELECT 
    s.name,
    r.career,
    r.score
FROM students s
JOIN recommendations r ON s.id = r.student_id
WHERE r.score > 85
ORDER BY r.score DESC;


-- ============================================================
-- STEP 7: UPDATE QUERIES
-- ============================================================

-- Update student CGPA
UPDATE students 
SET cgpa = 8.8 
WHERE id = 1;

-- Update recommendation score
UPDATE recommendations 
SET score = 95 
WHERE id = 1;

-- Update student skills
UPDATE students 
SET skills = 'Python, Java, React, Node.js, MongoDB' 
WHERE id = 1;


-- ============================================================
-- STEP 8: DELETE QUERIES
-- ============================================================

-- Delete a specific recommendation
DELETE FROM recommendations WHERE id = 5;

-- Delete a student (will also delete their recommendations if CASCADE is set)
DELETE FROM students WHERE id = 10;

-- Delete all feedback for a student
DELETE FROM feedback WHERE student_id = 1;


-- ============================================================
-- STEP 9: ANALYTICS QUERIES
-- ============================================================

-- Count total students
SELECT COUNT(*) as total_students FROM students;

-- Count total recommendations
SELECT COUNT(*) as total_recommendations FROM recommendations;

-- Average CGPA of all students
SELECT AVG(cgpa) as average_cgpa FROM students;

-- Department with highest average CGPA
SELECT 
    department,
    AVG(cgpa) as avg_cgpa
FROM students
GROUP BY department
ORDER BY avg_cgpa DESC
LIMIT 1;

-- Most popular career recommendation
SELECT 
    career,
    COUNT(*) as recommendation_count
FROM recommendations
GROUP BY career
ORDER BY recommendation_count DESC
LIMIT 1;


-- ============================================================
-- STEP 10: SEARCH QUERIES
-- ============================================================

-- Search students by name
SELECT * FROM students 
WHERE name LIKE '%Kumar%';

-- Search by department
SELECT * FROM students 
WHERE department = 'Computer Science';

-- Search recommendations by career
SELECT * FROM recommendations 
WHERE career LIKE '%Engineer%';

-- Find students interested in specific topic
SELECT * FROM students 
WHERE interests LIKE '%AI%';

-- Find students with specific skill
SELECT * FROM students 
WHERE skills LIKE '%Python%';


-- ============================================================
-- STEP 11: ADVANCED QUERIES
-- ============================================================

-- Students with no recommendations
SELECT s.* 
FROM students s
LEFT JOIN recommendations r ON s.id = r.student_id
WHERE r.id IS NULL;

-- Average score per department
SELECT 
    s.department,
    AVG(r.score) as avg_recommendation_score
FROM students s
JOIN recommendations r ON s.id = r.student_id
GROUP BY s.department;

-- Top 3 careers per department
SELECT 
    s.department,
    r.career,
    COUNT(*) as count
FROM students s
JOIN recommendations r ON s.id = r.student_id
GROUP BY s.department, r.career
ORDER BY s.department, count DESC;

-- Students and their best career match
SELECT 
    s.name,
    s.department,
    r.career,
    r.score
FROM students s
JOIN recommendations r ON s.id = r.student_id
WHERE r.score = (
    SELECT MAX(score) 
    FROM recommendations 
    WHERE student_id = s.id
);


-- ============================================================
-- STEP 12: DATA MAINTENANCE
-- ============================================================

-- Check table structure
PRAGMA table_info(students);
PRAGMA table_info(recommendations);
PRAGMA table_info(feedback);

-- Check indexes
SELECT * FROM sqlite_master WHERE type = 'index';

-- Vacuum database (optimize storage)
VACUUM;

-- Check database integrity
PRAGMA integrity_check;


-- ============================================================
-- STEP 13: BACKUP QUERIES
-- ============================================================

-- Export all student data
SELECT * FROM students;

-- Export complete dataset with recommendations
SELECT 
    s.id as student_id,
    s.name,
    s.department,
    s.year,
    s.cgpa,
    s.interests,
    s.skills,
    r.career,
    r.score,
    r.salary,
    r.growth
FROM students s
LEFT JOIN recommendations r ON s.id = r.student_id;


-- ============================================================
-- QUICK REFERENCE COMMANDS
-- ============================================================

-- List all tables
.tables

-- Show table schema
.schema students

-- Output to CSV
.mode csv
.output students.csv
SELECT * FROM students;
.output stdout

-- Import from CSV
.mode csv
.import students.csv students

-- Show column headers
.headers on

-- Pretty print
.mode column
SELECT * FROM students;

-- ============================================================
-- END OF SQL COMMANDS
-- ============================================================