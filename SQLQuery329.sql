CREATE DATABASE MoviesApp;
USE MoviesApp;

CREATE TABLE Directors(
Id INT PRIMARY KEY IDENTITY(1,1),
Name NVARCHAR(50),
Surname NVARCHAR(50)
);

CREATE TABLE Actors(
Id INT PRIMARY KEY IDENTITY(1,1),
Name NVARCHAR(50),
Surname NVARCHAR(50)
);

CREATE TABLE Languages(
Id INT PRIMARY KEY IDENTITY(1,1),
Name NVARCHAR(50)
);

CREATE TABLE Movies(
Id INT PRIMARY KEY IDENTITY(1,1),
Name NVARCHAR(100),
Description NVARCHAR(MAX),
CoverPhoto NVARCHAR(255),
DirectorId INT,
LanguageId INT,
FOREIGN KEY (DirectorId) REFERENCES Directors(Id),
FOREIGN KEY (LanguageId) REFERENCES Languages(Id)
);

CREATE TABLE Genres(
Id INT PRIMARY KEY IDENTITY(1,1),
Name NVARCHAR(50)
);

CREATE TABLE MoviesActors(
MovieId INT,
ActorId INT,
PRIMARY KEY (MovieId, ActorId),
FOREIGN KEY (MovieId) REFERENCES Movies(Id),
FOREIGN KEY (ActorId) REFERENCES Actors(Id)
);

CREATE TABLE MoviesGenres(
MovieId INT,
GenreId INT,
PRIMARY KEY (MovieId, GenreId),
FOREIGN KEY (MovieId) REFERENCES Movies(Id),
FOREIGN KEY (GenreId) REFERENCES Genres(Id)
);

---Director's--
INSERT INTO Directors (Name, Surname) VALUES ('Emin', 'Sadiqov');
INSERT INTO Directors (Name, Surname) VALUES ('Jamal', 'Aliyev');
INSERT INTO Directors (Name, Surname) VALUES ('Malik', 'Israfilov');

---Actor's---
INSERT INTO Actors (Name, Surname) VALUES ('Ramin', 'Abbaszade');
INSERT INTO Actors (Name, Surname) VALUES ('Elmin', 'Agalarov');
INSERT INTO Actors (Name, Surname) VALUES ('Emiliya', 'Huseynli');

---Languages---
INSERT INTO Languages (Name) VALUES ('English');
INSERT INTO Languages (Name) VALUES ('Spanish');
INSERT INTO Languages (Name) VALUES ('French');

---Movies---
INSERT INTO Movies (Name, Description, CoverPhoto, DirectorId, LanguageId) VALUES ('Spider-Man', 'Action', 'spider-man.jpg', 2, 1);
INSERT INTO Movies (Name, Description, CoverPhoto, DirectorId, LanguageId) VALUES ('Drive', 'A crime drama', 'drive.jpg', 3, 1);
INSERT INTO Movies (Name, Description, CoverPhoto, DirectorId, LanguageId) VALUES ('Sonic', 'Animation', 'sonic.jpg', 1, 1);

---Genres---
INSERT INTO Genres (Name) VALUES ('Action');
INSERT INTO Genres (Name) VALUES ('Drama');
INSERT INTO Genres (Name) VALUES ('Animation');

---MoviesActors---
INSERT INTO MoviesActors (MovieId, ActorId) VALUES (1, 1);
INSERT INTO MoviesActors (MovieId, ActorId) VALUES (2, 2);
INSERT INTO MoviesActors (MovieId, ActorId) VALUES (3, 3);

---MoviesGenres---
INSERT INTO MoviesGenres (MovieId, GenreId) VALUES (1, 1);
INSERT INTO MoviesGenres (MovieId, GenreId) VALUES (2, 2);
INSERT INTO MoviesGenres (MovieId, GenreId) VALUES (3, 3);


CREATE PROCEDURE GetDirectorMoviesAndLanguages
    @directorId INT
AS
BEGIN
    SELECT 
        M.Name AS MovieName, 
        L.Name AS LanguageName
    FROM Movies M
    JOIN Languages L ON M.LanguageId = L.Id
    WHERE M.DirectorId = @directorId;
END;

EXEC GetDirectorMoviesAndLanguages @directorId = 2;

CREATE FUNCTION GetMoviesCountByLanguage
    (@languageId INT)
RETURNS INT
AS
BEGIN
    DECLARE @movieCount INT;
    SELECT @movieCount = COUNT(*)
    FROM Movies
    WHERE LanguageId = @languageId;
    RETURN @movieCount;
END;

SELECT dbo.GetMoviesCountByLanguage(1);

CREATE PROCEDURE GetMoviesAndDirectorsByGenre
    @genreId INT
AS
BEGIN
    SELECT 
        M.Name AS MovieName, 
        D.Name AS DirectorName, 
        D.Surname AS DirectorSurname
    FROM Movies M
    JOIN MoviesGenres MG ON M.Id = MG.MovieId
    JOIN Directors D ON M.DirectorId = D.Id
    WHERE MG.GenreId = @genreId;
END;

EXEC GetMoviesAndDirectorsByGenre @genreId = 2;

CREATE FUNCTION IsActorInMoreThanThreeMovies
    (@actorId INT)
RETURNS INT
AS
BEGIN
    DECLARE @movieCount INT;

    SELECT @movieCount = COUNT(*)
    FROM MoviesActors
    WHERE ActorId = @actorId;

    IF @movieCount > 3
        RETURN 1;
    ELSE
        RETURN 0;
END;


SELECT dbo.IsActorInMoreThanThreeMovies(1);

CREATE TRIGGER ShowMoviesDirectorsAfterInsert
ON Movies
AFTER INSERT
AS
BEGIN
    SELECT 
        M.Name AS MovieName,
        D.Name AS DirectorName,
        D.Surname AS DirectorSurname,
        L.Name AS LanguageName
    FROM Movies M
    JOIN Directors D ON M.DirectorId = D.Id
    JOIN Languages L ON M.LanguageId = L.Id;
END;

