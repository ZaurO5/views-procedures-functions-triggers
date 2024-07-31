CREATE TABLE [Group] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    [Limit] INT NOT NULL,
    BeginDate DATE,
    EndDate DATE
);

CREATE TABLE Student (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    Surname NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(15),
    BirthDate DATE NOT NULL,
    GPA DECIMAL(3, 2),
    GroupId INT,
    FOREIGN KEY (GroupId) REFERENCES [Group](Id)
);

INSERT INTO [Group] (Name, [Limit], BeginDate, EndDate) VALUES 
('Group A', 10, '2024-09-01', '2025-06-30'),
('Group B', 15, '2024-09-01', '2025-06-30');

INSERT INTO Student (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId) 
VALUES 
('Zaur', 'Huseynov', 'zaur2005@gmail.com', '+994506823924', '2005-09-27', 3.8, 1),
('Ali', 'Ibrahimov', 'aliibra@mail.com', '+994552394618', '2001-08-24', 3.9, 2);

CREATE TRIGGER CheckGroupLimit
ON Student
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @validInserts TABLE (
        Name NVARCHAR(50),
        Surname NVARCHAR(50),
        Email NVARCHAR(50),
        PhoneNumber NVARCHAR(20),
        BirthDate DATE,
        GPA DECIMAL(3, 2),
        GroupId INT
    );
    INSERT INTO @validInserts (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId)
    SELECT i.Name, i.Surname, i.Email, i.PhoneNumber, i.BirthDate, i.GPA, i.GroupId
    FROM inserted i
    JOIN [Group] g ON i.GroupId = g.Id
    WHERE (SELECT COUNT(*) FROM Student WHERE GroupId = i.GroupId) < g.[Limit];
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN [Group] g ON i.GroupId = g.Id
        WHERE (SELECT COUNT(*) FROM Student WHERE GroupId = i.GroupId) >= g.[Limit]
    )
    BEGIN
        THROW 51000, 'Group limit reached. Cannot add more students.', 1;
    END
    INSERT INTO Student (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId)
    SELECT Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId
    FROM @validInserts;
END;

CREATE TRIGGER CheckStudentAge_New
ON Student
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @invalidCount INT;

    INSERT INTO Student (Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId)
    SELECT Name, Surname, Email, PhoneNumber, BirthDate, GPA, GroupId
    FROM inserted
    WHERE DATEDIFF(YEAR, BirthDate, GETDATE()) > 16;

    SELECT @invalidCount = COUNT(*)
    FROM inserted
    WHERE DATEDIFF(YEAR, BirthDate, GETDATE()) <= 16;

    IF @invalidCount > 0
    BEGIN
        THROW 51000, 'Student must be older than 16 years.', 1;
    END
END;

CREATE FUNCTION GetAverageGPA
    (@groupId INT)
RETURNS DECIMAL(3, 2)
AS
BEGIN
    RETURN (SELECT AVG(GPA) FROM Student WHERE GroupId = @groupId);
END;

