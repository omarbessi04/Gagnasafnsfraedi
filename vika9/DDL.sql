DROP TABLE IF EXISTS Learner;
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS Milestones;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Languages;
DROP TABLE IF EXISTS Assignments;
DROP TABLE IF EXISTS Exams;
DROP TABLE IF EXISTS Exam_Questions;
DROP TABLE IF EXISTS Followers;
DROP TABLE IF EXISTS Squads;
DROP TABLE IF EXISTS Sponsees;
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Subscribers;

-- A: Table to store languages
CREATE TABLE Languages (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    native_speakers INT
);

-- B: Table to store courses
CREATE TABLE Courses (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date DATE,
    difficulty_level INT,
    language_id INT,
    FOREIGN KEY (language_id) REFERENCES Languages(id)
);

-- C: Table to store subscribers
CREATE TABLE Subscribers (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE,
    position CHAR(7) -- "teacher" or "learner"
);

-- When a learner completes a milestone, their grade is stored.
CREATE TABLE Learner (
    learner_id INT PRIMARY KEY,
    last_login DATE,
    experience_points INT,
    milestone_id INT,
    milestone_grade INT,
    squad_id INT,
    FOREIGN KEY (squad_id) REFERENCES Squads(id),
    FOREIGN KEY (learner_id) REFERENCES Subscribers(id),
    FOREIGN KEY (milestone_id) REFERENCES Milestones(id)
);

-- D: Table to store teachers
CREATE TABLE Teachers (
    id INT PRIMARY KEY,
    subscriber_id INT UNIQUE,
    phone_number INT UNIQUE,
    office_hours VARCHAR(100),
    -- composite attribute
    bank VARCHAR(50),
    ledger VARCHAR(50),
    account_number VARCHAR(50),

    FOREIGN KEY (subscriber_id) REFERENCES Subscribers(id)
);

-- E: Table to store reviews
CREATE TABLE Reviews (
    id INT PRIMARY KEY,
    reviewer_id INT CHECK (reviewer_id != teacher_id),
    teacher_id INT CHECK (reviewer_id != teacher_id),
    stars INT CHECK (stars >= 1 AND stars <= 5),
    FOREIGN KEY (reviewer_id) REFERENCES Subscribers(id),
    FOREIGN KEY (teacher_id) REFERENCES Teachers(id)
);

-- F: Table to store milestones
CREATE TABLE Milestones (
    id INT PRIMARY KEY,
    credits INT,
    course_id INT,
    type VARCHAR(50),
    FOREIGN KEY (course_id) REFERENCES Courses(id)
);

-- H: Table to store assignments and exams
CREATE TABLE Assignments (
    assignment_id INT PRIMARY KEY,
    due_date DATE,
    FOREIGN KEY (assignment_id) REFERENCES Milestones(id)
);

CREATE TABLE Exams (
    exam_id INT PRIMARY KEY,
    exam_date DATE,
    duration INT,
    FOREIGN KEY (exam_id) REFERENCES Milestones(id)
);
CREATE TABLE Exam_Questions (
    id INT PRIMARY KEY,
    exam_id INT,
    text VARCHAR(500),
    weight INT,
    FOREIGN KEY (exam_id) REFERENCES Milestones(id)
);

-- I: Table to store squads
CREATE TABLE Followers (
    follower_id INT,
    followee_id INT,
    FOREIGN KEY (follower_id) REFERENCES Subscribers(id),
    FOREIGN KEY (followee_id) REFERENCES Subscribers(id)
);

CREATE TABLE Squads (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    meeting_point_address VARCHAR(255),
    squad_language INT,
    FOREIGN KEY (squad_language) REFERENCES Languages(id)
);

-- J: Table to store sponsorships
CREATE TABLE Sponsees (
    id INT PRIMARY KEY,
    nominator_id INT,
    nominated_learner INT CHECK (nominated_squad IS NULL),
    nominated_squad INT CHECK (nominated_learner IS NULL),
    grant_amount INT,
    FOREIGN KEY (nominated_learner) REFERENCES Learner(id),
    FOREIGN KEY (nominator) REFERENCES Teachers(id)
)