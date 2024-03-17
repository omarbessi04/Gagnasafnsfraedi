DROP TABLE IF EXISTS Sells;
DROP TABLE IF EXISTS Coffees;
DROP TABLE IF EXISTS Coffeehouses;

CREATE TABLE Coffees (
	name VARCHAR(20) PRIMARY KEY,
	manufacturer VARCHAR(20)
);

CREATE TABLE Coffeehouses (
	name VARCHAR(20) PRIMARY KEY,
	address VARCHAR(20),
	license VARCHAR(20)
);

CREATE TABLE Sells (
	coffeehouse CHAR(20) REFERENCES Coffeehouses(name),
	coffee VARCHAR(20) REFERENCES Coffees(name),
	price INT,
	PRIMARY KEY(coffeehouse, coffee)
);

INSERT INTO Coffees (name, manufacturer) VALUES ('Bloop', 'Skraga');

SELECT * FROM Coffees