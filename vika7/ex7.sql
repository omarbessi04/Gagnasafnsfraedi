-- DDL

-- Cleanup
drop table if exists Tournaments;
drop table if exists PDF_Employee;
drop table if exists Membership;
drop table if exists Clubs;
drop table if exists Degree;
drop table if exists Danes;

-- Creating tables
create table Danes (
    ID int,
    name varchar(200) not null,
    nationality varchar(20) not null,
    primary key (ID)
);

create table Degree (
    ID int,
    DID int references Danes(ID),
    level varchar(20) not null,
    subject varchar(20) not null,
    institution varchar(50) not null,
    year int not null,
    primary key(DID),
    unique (DID, level, subject)
);

create table Clubs (
    ID int,
    name varchar(20) not null,
    nationality varchar(20) not null,
    primary key (ID),
    unique (name, nationality)
);

create table Membership (
    DID int references Danes(ID),
    CID int references Clubs(ID),
    start_date date not null,
    end_date date,
    primary key(DID, CID, start_date)
);

create table PDF_Employee (
    ID int,
    name varchar(200) not null,
    primary key (ID)
);

create table Tournaments (
    ID int,
    CID int references Clubs(ID),
    EID int references PDF_Employee(ID) not null,
    name varchar(20) not null,
    venue varchar(20) not null,
    date date not null,
    primary key (ID)
);