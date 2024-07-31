CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL
);

CREATE TABLE Positions (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    [Limit] INT NOT NULL
);

CREATE TABLE Workers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    Surname NVARCHAR(50) NOT NULL,
    PhoneNumber NVARCHAR(15),
    Salary DECIMAL(10, 2) NOT NULL,
    BirthDate DATE NOT NULL,
    DepartmentId INT,
    PositionId INT,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
    FOREIGN KEY (PositionId) REFERENCES Positions(Id)
);

INSERT INTO Departments (Name) VALUES 
('HR'),
('IT'),
('Finance');

INSERT INTO Positions (Name, [Limit]) VALUES 
('Manager', 5),
('Developer', 10),
('Analyst', 7);

INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId) 
VALUES 
('Ali', 'Ibrahimov', '+994503845319', 60000, '1998-03-15', 1, 1),
('Zaur', 'Huseynov', '+994702915394', 80000, '2002-05-20', 2, 2);

CREATE FUNCTION GetAverageSalaryByDepartment
    (@departmentId INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN (SELECT AVG(Salary) FROM Workers WHERE DepartmentId = @departmentId);
END;
GO

CREATE TRIGGER CheckWorkerAge
ON Workers
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @birthDate DATE, @age INT;

    SELECT @birthDate = BirthDate FROM inserted;
    SET @age = DATEDIFF(YEAR, @birthDate, GETDATE());

    IF @age >= 18
    BEGIN
        INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId)
        SELECT Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId FROM inserted;
    END
    ELSE
    BEGIN
        RAISERROR('Worker must be at least 18 years old.', 16, 1);
    END
END;
GO

CREATE TRIGGER CheckPositionLimit
ON Workers
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @positionId INT;
    DECLARE @limit INT;
    DECLARE @currentCount INT;
    SELECT @positionId = PositionId FROM inserted;
    SELECT @limit = [Limit] FROM Positions WHERE Id = @positionId;
    SELECT @currentCount = COUNT(*) FROM Workers WHERE PositionId = @positionId;

    IF @currentCount < @limit
    BEGIN
        INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId)
        SELECT Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId
        FROM inserted;
    END
    ELSE
    BEGIN
        RAISERROR('Cannot add more workers.', 16, 1);
    END
END;
GO
