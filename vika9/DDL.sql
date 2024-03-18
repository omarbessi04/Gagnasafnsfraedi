-- HW4
-- Student names: Elísabet Jóhannesdóttir, Eva Natalía & Ómar Bessi Ómarsson

-- DDL for Awesome University's Language Learning Platform

-- Cleanup
DROP TABLE IF EXISTS Registered;
DROP TABLE IF EXISTS Sponsees;
DROP TABLE IF EXISTS Followers;
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Learner;
DROP TABLE IF EXISTS Squads;
DROP TABLE IF EXISTS Subscribers;
DROP TABLE IF EXISTS Exam_Questions;
DROP TABLE IF EXISTS Exams;
DROP TABLE IF EXISTS Assignments;
DROP TABLE IF EXISTS Milestones;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Languages;

-- First create all tables related to the system
-- then create all user related tables

-- System tables

-- The database must keep track of all languages that are taught on the platform.
CREATE TABLE Languages (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    native_speakers INT
);

-- The platform hosts language courses.
CREATE TABLE Courses (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date DATE,
    difficulty_level INT,
    language_id INT,
    FOREIGN KEY (language_id) REFERENCES Languages(id)
);

-- Each course has at least one milestone.
CREATE TABLE Milestones (
    id INT PRIMARY KEY,
    credits INT,
    course_id INT,
    type VARCHAR(50),
    FOREIGN KEY (course_id) REFERENCES Courses(id)
);

-- Milestones can be divided into Assignments and Exams. 
CREATE TABLE Assignments (
    assignment_id INT PRIMARY KEY,
    due_date DATE,
    FOREIGN KEY (assignment_id) REFERENCES Milestones(id)
);

-- Same requirement as earlier.
CREATE TABLE Exams (
    exam_id INT PRIMARY KEY,
    exam_date DATE,
    duration INT,
    FOREIGN KEY (exam_id) REFERENCES Milestones(id)
);

-- Exams can be partitioned into one or more questions.
CREATE TABLE Exam_Questions (
    id INT PRIMARY KEY,
    exam_id INT,
    text VARCHAR(500),
    weight INT,
    FOREIGN KEY (exam_id) REFERENCES Milestones(id)
);


-- User related tables


-- To use the platform, one must sign up as a subscriber.
CREATE TABLE Subscribers (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE,
    position CHAR(7) -- "teacher" or "learner"
);

-- Learners may be part of squads for studying together or socializing. 
CREATE TABLE Squads (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    meeting_point_address VARCHAR(255),
    squad_language INT,
    FOREIGN KEY (squad_language) REFERENCES Languages(id)
);

-- Learners can be parts of squads,
-- and the grades of their completed milestones are stored.
CREATE TABLE Learner (
    id INT PRIMARY KEY,
    last_login DATE,
    experience_points INT,
    milestone_id INT,
    milestone_grade INT,
    squad_id INT,
    FOREIGN KEY (squad_id) REFERENCES Squads(id),
    FOREIGN KEY (id) REFERENCES Subscribers(id),
    FOREIGN KEY (milestone_id) REFERENCES Milestones(id)
);

-- Subscribers can also be teachers.
CREATE TABLE Teachers (
    id INT PRIMARY KEY,
    subscriber_id INT UNIQUE,
    phone_number INT UNIQUE,
    office_hours VARCHAR(100),
    -- composite attribute (
    bank VARCHAR(50),
    ledger VARCHAR(50),
    account_number VARCHAR(50),
    -- )

    FOREIGN KEY (subscriber_id) REFERENCES Subscribers(id)
);

-- Learners can review teachers.
CREATE TABLE Reviews (
    id INT PRIMARY KEY,
    reviewer_id INT CHECK (reviewer_id != teacher_id),
    teacher_id INT CHECK (reviewer_id != teacher_id),
    stars INT CHECK (stars >= 1 AND stars <= 5),
    FOREIGN KEY (reviewer_id) REFERENCES Subscribers(id),
    FOREIGN KEY (teacher_id) REFERENCES Teachers(id)
);

-- Learners can follow each other on the platform.
CREATE TABLE Followers (
    follower_id INT,
    followee_id INT,
    UNIQUE(follower_id, followee_id),
    FOREIGN KEY (follower_id) REFERENCES Subscribers(id),
    FOREIGN KEY (followee_id) REFERENCES Subscribers(id)
);

-- Teachers may nominate selected learners and squads for sponsorship
CREATE TABLE Sponsees (
    id INT PRIMARY KEY,
    nominator_id INT,
    nominated_learner INT CHECK (nominated_squad IS NULL),
    nominated_squad INT CHECK (nominated_learner IS NULL),
    grant_amount INT,
    FOREIGN KEY (nominated_learner) REFERENCES Learner(id),
    FOREIGN KEY (nominator_id) REFERENCES Teachers(id)
);

-- Students can be registered to courses:
CREATE TABLE Registered (
    subscriber_id INT,
    course_id INT,
    PRIMARY KEY (subscriber_id, course_id),
    FOREIGN KEY (subscriber_id) REFERENCES Subscribers(id),
    FOREIGN KEY (course_id) REFERENCES Courses(id)
)