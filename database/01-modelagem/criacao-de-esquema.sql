
-- Tabela para registrar reproduções de músicas
CREATE TABLE dbo.SongPlays
(
    SongPlayID INT IDENTITY(1,1) NOT NULL,
    SongID INT NOT NULL,
    UserID INT NOT NULL,
    LocationID INT NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    StartTimeUTC DATETIMEOFFSET(7) NOT NULL, -- Horário UTC da reprodução
    Latitude NVARCHAR(20) NOT NULL,
    Longitude NVARCHAR(20) NOT NULL
)
GO

-- Tabela para armazenar informações sobre álbuns
CREATE TABLE dbo.Albums
(
    AlbumID INT NOT NULL IDENTITY (1,1),
    [Name] NVARCHAR(50) NOT NULL,
    ReleaseDate DATE NOT NULL,
    ArtistID INT NOT NULL,
    LabelID INT NOT NULL
)
GO

-- Tabela para armazenar informações sobre músicas
CREATE TABLE dbo.Songs
(
    SongID INT NOT NULL IDENTITY (1,1),
    Title NVARCHAR(50) NOT NULL,
    Duration TIME NOT NULL,
    ReleaseDate DATE NOT NULL,
    ArtistID INT NOT NULL,
    AlbumID INT NOT NULL,
    GenreID INT NOT NULL
)
GO

-- Tabela para armazenar gêneros musicais
CREATE TABLE dbo.Genre
(
    GenreID INT NOT NULL IDENTITY (1,1),
    [Name] NVARCHAR(50) NOT NULL
)
GO

-- Tabela para armazenar informações sobre localizações
CREATE TABLE dbo.Location
(
    LocationID INT NOT NULL IDENTITY (1,1),
    TimeZone NVARCHAR(MAX) NOT NULL,
    Country NVARCHAR(50) NOT NULL
)
GO

-- Tabela para armazenar informações sobre usuários
CREATE TABLE dbo.Users
(
    UserID INT NOT NULL IDENTITY (1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Gender NCHAR(1) NOT NULL,
    Email NVARCHAR(50) NOT NULL,
    [Password] NVARCHAR(10) NOT NULL, -- Em produção, utilize hash seguro
    BirthDate DATE NOT NULL,
    DateCreated DATE NOT NULL,
    LocationID INT NOT NULL
)
GO

-- Tabela para armazenar informações sobre gravadoras
CREATE TABLE dbo.Labels
(
    LabelID INT NOT NULL IDENTITY (1,1),
    [Name] NVARCHAR(50) NOT NULL,
    LocationID INT NOT NULL
)
GO

-- Tabela para armazenar informações sobre artistas
CREATE TABLE dbo.Artists
(
    ArtistID INT NOT NULL IDENTITY (1,1),
    [Name] NVARCHAR(50) NOT NULL,
    DateCreated DATE NOT NULL,
    LocationID INT NOT NULL
)
GO

-- Adicionar chaves primárias (PK) para garantir unicidade
ALTER TABLE dbo.Users
ADD CONSTRAINT PK_Users_UserID PRIMARY KEY CLUSTERED (UserID ASC)
GO
ALTER TABLE dbo.Labels
ADD CONSTRAINT PK_Labels_LabelID PRIMARY KEY CLUSTERED (LabelID ASC)
GO
ALTER TABLE dbo.SongPlays
ADD CONSTRAINT PK_SongPlays_SongPlayID PRIMARY KEY CLUSTERED (SongPlayID ASC)
GO
ALTER TABLE dbo.Albums
ADD CONSTRAINT PK_Albums_AlbumID PRIMARY KEY CLUSTERED (AlbumID ASC)
GO
ALTER TABLE dbo.Songs
ADD CONSTRAINT PK_Songs_SongID PRIMARY KEY CLUSTERED (SongID ASC)
GO
ALTER TABLE dbo.Location
ADD CONSTRAINT PK_Location_LocationID PRIMARY KEY CLUSTERED (LocationID ASC)
GO
ALTER TABLE dbo.Genre
ADD CONSTRAINT PK_Genre_GenreID PRIMARY KEY CLUSTERED (GenreID ASC)
GO
ALTER TABLE dbo.Artists
ADD CONSTRAINT PK_Artists_ArtistID PRIMARY KEY CLUSTERED (ArtistID ASC)
GO

-- Adicionar chaves estrangeiras (FK) para garantir integridade referencial
ALTER TABLE dbo.Users
ADD CONSTRAINT FK_Users_LocationID FOREIGN KEY (LocationID)
REFERENCES dbo.Location (LocationID)
GO
ALTER TABLE dbo.Labels
ADD CONSTRAINT FK_Labels_LocationID FOREIGN KEY (LocationID)
REFERENCES dbo.Location (LocationID)
GO
ALTER TABLE dbo.Artists
ADD CONSTRAINT FK_Artists_LocationID FOREIGN KEY (LocationID)
REFERENCES dbo.Location (LocationID)
GO
ALTER TABLE dbo.SongPlays
ADD CONSTRAINT FK_SongPlays_LocationID FOREIGN KEY (LocationID)
REFERENCES dbo.Location (LocationID)
GO
ALTER TABLE dbo.SongPlays
ADD CONSTRAINT FK_SongPlays_SongID FOREIGN KEY (SongID)
REFERENCES dbo.Songs (SongID)
GO
ALTER TABLE dbo.SongPlays
ADD CONSTRAINT FK_SongPlays_UserID FOREIGN KEY (UserID)
REFERENCES dbo.Users (UserID)
GO
ALTER TABLE dbo.Albums
ADD CONSTRAINT FK_Albums_ArtistID FOREIGN KEY (ArtistID)
REFERENCES dbo.Artists (ArtistID)
GO
ALTER TABLE dbo.Albums
ADD CONSTRAINT FK_Albums_LabelID FOREIGN KEY (LabelID)
REFERENCES dbo.Labels (LabelID)
GO
ALTER TABLE dbo.Songs
ADD CONSTRAINT FK_Songs_ArtistID FOREIGN KEY (ArtistID)
REFERENCES dbo.Artists (ArtistID)
GO
ALTER TABLE dbo.Songs
ADD CONSTRAINT FK_Songs_AlbumID FOREIGN KEY (AlbumID)
REFERENCES dbo.Albums (AlbumID)
GO
ALTER TABLE dbo.Songs
ADD CONSTRAINT FK_Songs_GenreID FOREIGN KEY (GenreID)
REFERENCES dbo.Genre (GenreID)
GO