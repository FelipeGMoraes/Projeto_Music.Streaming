
-- Tabela para registrar reproduções de músicas
CREATE TABLE dbo.SongPlays
(
SongPlayID [int] IDENTITY(1,1) NOT NULL,
SongID int NOT NULL,
UserID int NOT NULL,
LocationID int NOT NULL,
StartTime datetime NOT NULL,
EndTime datetime NOT NULL,
[StartTime UTC] datetimeoffset(7) NOT NULL,
Latitude nvarchar(20) NOT NULL,
Longitude nvarchar(20) NOT NULL
)
GO

-- Tabela para armazenar informações sobre álbuns
CREATE TABLE dbo.Albums
(
AlbumID int not null IDENTITY (1,1),
[Name] nvarchar(50) not null,
ReleaseDate date not null,
ArtistID int not null,
LabelID int not null
)
GO

-- Tabela para armazenar informações sobre músicas
CREATE TABLE dbo.Songs
(
SongID int not null IDENTITY (1,1),
Title nvarchar(50) not null,
Duration time not null,
ReleaseDate date not null,
ArtistID int not null,
AlbumID int not null,
GenreID int not null
)
GO

-- Tabela para armazenar gêneros musicais
CREATE TABLE dbo.Genre
(
GenreID int not null IDENTITY (1,1),
[Name] nvarchar(50) not null
)
GO

-- Tabela para armazenar informações sobre localizações
CREATE TABLE dbo. Location
(
LocationID int not null IDENTITY (1,1),
TimeZone nvarchar(max) not null,
Country nvarchar(50) not null
)
GO

-- Tabela para armazenar informações sobre usuários
CREATE TABLE dbo.Users
(
UserID int not null IDENTITY (1,1),
FirstName nvarchar(50) not null,
LastName nvarchar(50) not null,
Gender nchar(1) not null,
Email nvarchar(50) not null,
[Password] nvarchar(10) not null,
BirthDate date not null,
DateCreated date not null,
LocationID int not null
)
GO

-- Tabela para armazenar informações sobre gravadoras
CREATE TABLE dbo.Labels
(
LabelID int not null IDENTITY (1,1),
[Name] nvarchar(50) not null,
LocationID int not null
)
GO

-- Tabela para armazenar informações sobre artistas
CREATE TABLE dbo.Artists
(
ArtistID int not null IDENTITY (1,1),
[Name] nvarchar(50) not null,
DateCreated date not null,
LocationID int not null
)
GO

-- Adicionar chaves estrangeiras para relacionar tabelas e garantir a integridade referencial

ALTER TABLE dbo.Users
ADD CONSTRAINT PK_Users_UserID
PRIMARY KEY CLUSTERED (UserID ASC)
GO

ALTER TABLE dbo.Labels
ADD CONSTRAINT PK_Labels_LabelID
PRIMARY KEY CLUSTERED (LabelID ASC)
GO

ALTER TABLE dbo.SongPlays
ADD CONSTRAINT PK_SongsPlays_SongPlayID
PRIMARY KEY CLUSTERED (SongPlayID ASC)
GO

ALTER TABLE dbo.Albums
ADD CONSTRAINT PK_Albums_AlbumID
PRIMARY KEY CLUSTERED (AlbumID ASC)
GO

ALTER TABLE dbo.Songs
ADD CONSTRAINT PK_Songs_SongID
PRIMARY KEY CLUSTERED (SongID ASC)
GO

ALTER TABLE dbo.Location
ADD CONSTRAINT PK_Location_LocationID
PRIMARY KEY CLUSTERED (LocationID ASC)
GO

ALTER TABLE dbo.Genre
ADD CONSTRAINT PK_Genre_GenreID
PRIMARY KEY CLUSTERED (GenreID ASC)
GO

ALTER TABLE dbo.Artists
ADD CONSTRAINT PK_Artists_ArtistID
PRIMARY KEY CLUSTERED (ArtistID ASC)
GO

-- Adicionar chaves estrangeiras para relacionar tabelas e garantir a integridade referencial entre elas
ALTER TABLE dbo.Users
ADD CONSTRAINT FK_LocationID FOREIGN KEY (LocationID)
REFERENCES dbo.Location (LocationID)
GO

ALTER TABLE dbo.Labels
ADD CONSTRAINT FK_Labels_Location FOREIGN KEY (LocationID)
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
ADD CONSTRAINT FK_Songs_ArtistsID FOREIGN KEY (ArtistID)
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