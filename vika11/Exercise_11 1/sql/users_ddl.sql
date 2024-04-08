-- DROP
DROP OWNED BY viewer;
DROP OWNED BY editor;
DROP OWNED BY theone;
DROP ROLE IF EXISTS viewer;
DROP ROLE IF EXISTS editor;
DROP ROLE IF EXISTS theone;
DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Roles CASCADE;

-- Roles
CREATE ROLE viewer WITH LOGIN ENCRYPTED PASSWORD '1337';

CREATE ROLE editor WITH LOGIN ENCRYPTED PASSWORD '42';

CREATE ROLE theone WITH LOGIN ENCRYPTED PASSWORD 'sdslsop1';


-- Tables
CREATE TABLE Roles (
    role_name VARCHAR(50) PRIMARY KEY
);

CREATE TABLE Users (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(20) UNIQUE NOT NULL,
    password_hashed VARCHAR NOT NULL,
    salt VARCHAR NOT NULL,
    role_name VARCHAR(50) NOT NULL REFERENCES Roles
);


-- Grant Privileges
-- viewer
GRANT SELECT ON Sports, Results, Competitions, Athletes, Gender TO viewer;

-- editor
GRANT SELECT, INSERT, UPDATE ON Sports, Results, Competitions, Athletes, Gender TO editor;

-- theone
GRANT USAGE ON SCHEMA public TO theone;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO theone;
GRANT USAGE ON SEQUENCE
    athletes_id_seq,
    sports_id_seq,
    competitions_id_seq
    TO theone;


-- Generated Data
INSERT INTO Roles VALUES ('viewer');
INSERT INTO Roles VALUES ('editor');
INSERT INTO Roles VALUES ('theone');
-- Password = Viewer, hashed password and salt using bcrypt
INSERT INTO Users (username, password_hashed, salt, role_name)
VALUES ('Viewer', '$2b$12$7hHYFkFemFip3CLyik71gOrcyjjsfFD43dMoyXneqy0Go/xO1oiWS', '$2b$12$7hHYFkFemFip3CLyik71gO', 'viewer');
-- Password = Editor, hashed password and salt using bcrypt
INSERT INTO Users (username, password_hashed, salt, role_name)
VALUES ('Editor', '$2b$12$pInU6CronWbVj3qTSE7pPevHmolMpYKvan1g6QV72kOphWe3zqps2', '$2b$12$pInU6CronWbVj3qTSE7pPe', 'editor');
-- Password = TheOne, hashed password and salt using bcrypt
INSERT INTO Users (username, password_hashed, salt, role_name)
VALUES ('TheOne', '$2b$12$Mbmx2nryEtMIAA3HPoMaLePyJeDsiVvLv2QQ0Xyg3Z5SaY6kcuHpi', '$2b$12$Mbmx2nryEtMIAA3HPoMaLe', 'theone');
