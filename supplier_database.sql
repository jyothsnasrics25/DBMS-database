DROP database supplier;
CREATE DATABASE supplier;
USE DATABASE supplier;

CREATE TABLE Supplier (
    s_id INT PRIMARY KEY,
    s_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE Part (
    p_id INT PRIMARY KEY,
    p_name VARCHAR(100) NOT NULL,
    color VARCHAR(30) NOT NULL
);

CREATE TABLE Catalog (
    s_id INT,
    p_id INT,
    cost DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (s_id, p_id),
    FOREIGN KEY (s_id)REFERENCES Supplier(s_id),
    FOREIGN KEY (p_id)REFERENCES Part(p_id),
    CHECK (cost >= 0)
);
INSERT INTO Supplier VALUES
(10001, 'Acme Widget', 'Bangalore'),
(10002, 'Johns', 'Kolkata'),
(10003, 'Vimal', 'Mumbai'),
(10004, 'Reliance', 'Delhi');

INSERT INTO Part VALUES
(20001, 'Book', 'Red'),
(20002, 'Pen', 'Red'),
(20003, 'Pencil', 'Green'),
(20004, 'Mobile', 'Green'),
(20005, 'Charger', 'Black');

INSERT INTO CATALOG VALUES
(10001, 20001, 10),
(10001, 20002, 10),
(10001, 20003, 30),
(10001, 20004, 10),
(10001, 20005, 10),
(10002, 20001, 10),
(10002, 20002, 20),
(10003, 20003, 30),
(10004, 20003, 40);

SELECT DISTINCT p.p_name    /*pnames of of parts for which there is some supplier*/
FROM Part p
JOIN Catalog c
ON p.p_id = c.p_id;

SELECT s.s_name          
FROM Supplier s
WHERE NOT EXISTS (
    SELECT *
    FROM Part p
    WHERE NOT EXISTS (
        SELECT *
        FROM Catalog c
        WHERE c.s_id = s.s_id
        AND c.p_id = p.p_id
    )
);

SELECT s.s_name
FROM Supplier s
WHERE NOT EXISTS (
    SELECT *
    FROM Part p
    WHERE p.color = 'Red'
    AND NOT EXISTS (
        SELECT *
        FROM Catalog c
        WHERE c.s_id = s.s_id
        AND c.p_id = p.p_id
    )
);

SELECT p.p_name
FROM Part p
JOIN Catalog c
ON p.p_id = c.p_id
JOIN Supplier s
ON c.s_id = s.s_id
WHERE s.s_name = 'Acme Widget Suppliers'
AND NOT EXISTS (
    SELECT *
    FROM Catalog c2
    WHERE c2.p_id = p.p_id
    AND c2.s_id <> s.s_id
);

SELECT DISTINCT c1.s_id
FROM Catalog c1
WHERE c1.cost > (
    SELECT AVG(c2.cost)
    FROM Catalog c2
    WHERE c2.p_id = c1.p_id
);

SELECT p.p_name, s.s_name, c1.cost
FROM Catalog c1
JOIN Part p
ON c1.p_id = p.p_id
JOIN Supplier s
ON c1.s_id = s.s_id
WHERE c1.cost = (
    SELECT MAX(c2.cost)
    FROM Catalog c2
    WHERE c2.p_id = c1.p_id
);

SELECT p.p_name, s.s_name, c.cost
FROM Supplier s
JOIN Catalog c ON s.s_id = c.s_id
JOIN Part p ON c.p_id = p.p_id
WHERE c.cost = (
    SELECT MAX(cost)
    FROM Catalog
);

SELECT s.s_name
FROM Supplier s
WHERE NOT EXISTS (
    SELECT *
    FROM Catalog c
    JOIN Part p ON c.p_id = p.p_id
    WHERE c.s_id = s.s_id
    AND p.color = 'Red'
);

SELECT s.s_name, SUM(c.cost) AS total_value
FROM Supplier s
JOIN Catalog c ON s.s_id = c.s_id
GROUP BY s.s_id, s.s_name;

SELECT s.s_name
FROM Supplier s
JOIN Catalog c ON s.s_id = c.s_id
WHERE c.cost < 20
GROUP BY s.s_id, s.s_name
HAVING COUNT(DISTINCT c.p_id) >= 2;

SELECT p.p_name, s.s_name, c.cost
FROM Supplier s
JOIN Catalog c ON s.s_id = c.s_id
JOIN Part p ON c.p_id = p.p_id
WHERE c.cost = (
    SELECT MIN(c2.cost)
    FROM Catalog c2
    WHERE c2.p_id = c.p_id
);

CREATE VIEW Expensive_Supplier AS
SELECT p.p_name, s.s_name, c.cost
FROM Supplier s
JOIN Catalog c ON s.s_id = c.s_id
JOIN Part p ON c.p_id = p.p_id
WHERE c.cost = (
    SELECT MAX(c2.cost)
    FROM Catalog c2
    WHERE c2.p_id = c.p_id
);

DELIMITER //

CREATE TRIGGER check_cost
BEFORE INSERT ON Catalog
FOR EACH ROW
BEGIN
    IF NEW.cost < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cost cannot be below 1';
    END IF;
END //

DELIMITER ;

ALTER TABLE Catalog
MODIFY cost DECIMAL(10,2) DEFAULT NULL;

DELIMITER //

CREATE TRIGGER default_cost
BEFORE INSERT ON Catalog
FOR EACH ROW
BEGIN
    IF NEW.cost IS NULL THEN
        SET NEW.cost = 10;
    END IF;
END //

DELIMITER ;

