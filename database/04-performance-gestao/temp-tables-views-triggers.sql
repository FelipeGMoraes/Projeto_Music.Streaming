-- Verificar variáveis do tipo @table
-- Criar lista de IDs de usuários de um país específico (ex: 'Brazil') e depois usar essa lista para outra consulta
DECLARE @UsuariosDoBrazil TABLE (
    UserID INT PRIMARY KEY NOT NULL
);

INSERT INTO @UsuariosDoBrazil (UserID)

SELECT u.UserID
FROM dbo.Users u
INNER JOIN dbo.Location l ON u.LocationID = l.LocationID
WHERE l.Country = 'Brazil';

SELECT sp.SongPlayID, s.Title AS Musica, u.FirstName AS NomeUsuario, sp.StartTime
FROM dbo.SongPlays sp
INNER JOIN dbo.Songs s ON sp.SongID = s.SongID
INNER JOIN dbo.Users u ON sp.UserID = u.UserID
WHERE sp.UserID IN (SELECT UserID FROM @UsuariosDoBrazil)
ORDER BY sp.StartTime DESC;
GO

-- Utilizar tabelas temporárias
-- Criar tabela temporária para contagem de reproduções por música
CREATE TABLE #ContagemReproducoesPorMusica (
    SongID INT PRIMARY KEY, -- Chave primária para melhor performance em joins
    TituloMusica NVARCHAR(50),
    TotalReproducoes INT
);

-- Index para otimizar consultas por TotalReproducoes
CREATE INDEX IX_TotalReproducoes ON #ContagemReproducoesPorMusica(TotalReproducoes DESC);

-- Inserir dados agregados na tabela temporária
INSERT INTO #ContagemReproducoesPorMusica (SongID, TituloMusica, TotalReproducoes)
SELECT
    s.SongID,
    s.Title,
    COUNT(sp.SongPlayID) AS TotalReproducoes
FROM
    dbo.Songs s
    LEFT JOIN dbo.SongPlays sp ON s.SongID = sp.SongID -- LEFT JOIN para incluir músicas não tocadas
GROUP BY
    s.SongID, s.Title;

-- Exemplo de uso: Listar as 10 músicas mais tocadas
SELECT TOP 10
    SongID,
    TituloMusica,
    TotalReproducoes
FROM
    #ContagemReproducoesPorMusica
ORDER BY
    TotalReproducoes DESC;

-- Converter Stored Procedure em View
-- Exemplo de conversão de uma Stored Procedure para View

-- Stored Procedure para buscar detalhes das músicas, incluindo artista, álbum e gênero
CREATE PROCEDURE dbo.ObterDetalhesDeTodasAsMusicas
AS
BEGIN
    SET NOCOUNT ON;

    SELECT s.SongID, s.Title AS Musica,
		ar.Name AS Artista, al.Name AS Album,
		g.Name AS Genero, s.Duration AS Duracao,
		s.ReleaseDate AS DataLancamentoMusica
    FROM dbo.Songs s
    INNER JOIN dbo.Artists ar ON s.ArtistID = ar.ArtistID
    INNER JOIN dbo.Albums al ON s.AlbumID = al.AlbumID
    INNER JOIN dbo.Genre g ON s.GenreID = g.GenreID;
END;
GO

EXEC dbo.ObterDetalhesDeTodasAsMusicas;
GO

-- Conversão para View
CREATE VIEW dbo.View_DetalhesMusicasCompletos AS
SELECT
    s.SongID,
    s.Title AS TituloMusica,
    ar.Name AS NomeArtista,
    al.Name AS NomeAlbum,
    g.Name AS NomeGenero,
    s.Duration AS Duracao,
    s.ReleaseDate AS DataLancamentoMusica
FROM
    dbo.Songs s
    INNER JOIN dbo.Artists ar ON s.ArtistID = ar.ArtistID
    INNER JOIN dbo.Albums al ON s.AlbumID = al.AlbumID
    INNER JOIN dbo.Genre g ON s.GenreID = g.GenreID;
GO

-- Para usar a View:
SELECT * FROM dbo.View_DetalhesMusicasCompletos;
GO


-- Criar Trigger para registrar operações na tabela Users, se não existir
-- Criando a tabela UserLog:
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'UserLog' AND xtype = 'U')
CREATE TABLE UserLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Action NVARCHAR(50) NOT NULL,
    ActionDate DATETIME DEFAULT GETDATE() NOT NULL
);
GO

-- Criar Trigger para a tabela dbo.UserTableTrigger_Detalhado
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'UserTableTrigger_Detalhado')
    DROP TRIGGER dbo'UserTableTrigger_Detalhado';
GO

CREATE TRIGGER UserTableTrigger_Detalhado
ON dbo.Users
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO UserLog (UserID, Action)
        SELECT UserID, 'INSERT'
        FROM inserted;
    END

    ELSE IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO UserLog (UserID, Action)
        SELECT i.UserID, 'UPDATE'
        FROM inserted i;
    END

    ELSE IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO UserLog (UserID, Action)
        SELECT UserID, 'DELETE'
        FROM deleted;
    END
END;
GO

-- Para testar:
INSERT INTO dbo.Users (FirstName, LastName, Gender, Email, [Password], BirthDate, DateCreated, LocationID)
VALUES ('Teste', 'Log', 'M', 'teste@log.com', 'senha123', '2000-01-01', GETDATE(), 1);
GO

UPDATE dbo.Users SET Email = 'teste.novo@log.com' WHERE FirstName = 'Teste';
GO

DELETE FROM dbo.Users WHERE FirstName = 'Teste';
GO

SELECT * FROM UserLog;