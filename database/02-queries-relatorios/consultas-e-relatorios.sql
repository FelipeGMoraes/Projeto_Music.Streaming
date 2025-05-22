-- Relatórios

-- 1 Lista alfabética de utilizadores
SELECT FirstName, LastName
FROM dbo.Users
ORDER BY FirstName, LastName;

-- 2 Lista alfabética de gênero musicais
SELECT Name AS Genre
FROM dbo.Genre
ORDER BY Name;

-- 3 Lista alfabética de gravadoras

SELECT Name AS Label
FROM dbo.Labels
ORDER BY Name;

-- 4 Lista alfabética de artistas, por países

SELECT A.Name AS Artists, L.Country
FROM dbo.Artists A
JOIN dbo.Location L ON A.LocationID = L.LocationID
ORDER BY L.Country, A.Name;

-- 5 Lista alfabética de artistas, gravadoras, gênero, nome do álbum

SELECT A.Name AS Artists, L.Name AS LabelName, G.Name AS GenreName, Al.Name AS AlbumName
FROM dbo.Albums Al
JOIN dbo.Artists A ON Al.ArtistID = A.ArtistID
JOIN dbo.Labels L ON Al.LabelID = L.LabelID
JOIN dbo.Songs S ON Al.AlbumID = S.AlbumID
JOIN dbo.Genre G ON S.GenreID = G.GenreID
GROUP BY A.Name, L.Name, G.Name, Al.Name
ORDER BY Artists, LabelName, GenreName, AlbumName;

-- 6 Lista dos 5 países com mais bandas

SELECT TOP 5 L.Country, COUNT(A.ArtistID) AS BandCount
FROM dbo.Artists A
JOIN dbo.Location L ON A.LocationID = L.LocationID
GROUP BY L.Country
ORDER BY BandCount DESC;

-- 7 Lista das 10 bandas com mais álbuns

SELECT TOP 10 A.Name AS Artists, COUNT(Al.AlbumID) AS AlbumCount
FROM dbo.Albums Al
JOIN dbo.Artists A ON Al.ArtistID = A.ArtistID
GROUP BY A.Name
ORDER BY AlbumCount DESC;

-- 8 Lista das 5 gravadoras com mais álbuns

SELECT TOP 5 L.Name AS LabelName, COUNT(Al.AlbumID) AS AlbumCount
FROM dbo.Albums Al
JOIN dbo.Labels L ON Al.LabelID = L.LabelID
GROUP BY L.Name
ORDER BY AlbumCount DESC;

-- 9 Lista dos 5 gêneros musicais com mais álbuns

SELECT TOP 5 G.Name AS GenreName, COUNT(S.AlbumID) AS AlbumCount
FROM dbo.Songs S
JOIN dbo.Genre G ON S.GenreID = G.GenreID
GROUP BY G.Name
ORDER BY AlbumCount DESC;

-- 10 Lista das 20 músicas mais longas, por albúm

SELECT TOP 20 S.Title AS SongTitle, S.Duration
FROM dbo.Songs S
ORDER BY S.Duration DESC;

-- 11 Lista das 20 músicas mais rápidas, por albúm

SELECT TOP 20 S.Title AS SongTitle, S.Duration
FROM dbo.Songs S
ORDER BY S.Duration ASC;

--12 Lista dos 10 álbuns que demoram mais tempo

SELECT TOP 10 Al.Name AS AlbumName, SUM(DATEDIFF(SECOND, '00:00:00', S.Duration)) AS DuracaoTotalEmSegundos
FROM dbo.Songs S
JOIN dbo.Albums Al ON S.AlbumID = Al.AlbumID
GROUP BY Al.Name
ORDER BY DuracaoTotalEmSegundos DESC;

-- 13 Quantas músicas tem em cada álbum?

SELECT Al.Name AS AlbumName, COUNT(S.SongID) AS SongCount
FROM dbo.Songs S
JOIN dbo.Albums Al ON S.AlbumID = Al.AlbumID
GROUP BY Al.Name
ORDER BY SongCount DESC;

-- 14 Quantas músicas demoram mais que 5 minutos, por albúm?

SELECT COUNT(S.SongID) AS SongsOver5Min
FROM dbo.Songs S
WHERE S.Duration > '00:05:00';

-- 15 Quais são as músicas mais ouvidas?

SELECT S.Title AS SongTitle, COUNT(SP.SongPlayID) AS PlayCount
FROM dbo.SongPlays SP
JOIN dbo.Songs S ON SP.SongID = S.SongID
GROUP BY S.Title
ORDER BY PlayCount DESC;

-- 16 Músicas mais ouvidas, por países, entre 00:00 e 08:00

SELECT S.Title AS SongTitle, L.Country, COUNT(SP.SongPlayID) AS PlayCount
FROM dbo.SongPlays SP
JOIN dbo.Songs S ON SP.SongID = S.SongID
JOIN dbo.Location L ON SP.LocationID = L.LocationID
WHERE CAST(SP.StartTime AS TIME) BETWEEN '00:00:00' AND '08:00:00'
GROUP BY S.Title, L.Country
ORDER BY L.Country, PlayCount DESC;

-- 17 Músicas mais ouvidas, por países, entre 08:00 e 16:00

SELECT S.Title AS SongTitle, L.Country, COUNT(SP.SongPlayID) AS PlayCount
FROM dbo.SongPlays SP
JOIN dbo.Songs S ON SP.SongID = S.SongID
JOIN dbo.Location L ON SP.LocationID = L.LocationID
WHERE CAST(SP.StartTime AS TIME) BETWEEN '08:00:00' AND '16:00:00'
GROUP BY S.Title, L.Country
ORDER BY L.Country, PlayCount DESC;

-- 18 Qual o gênero musical mais ouvido por países? 

SELECT L.Country, G.Name AS GenreName, COUNT(SP.SongPlayID) AS PlayCount
FROM dbo.SongPlays SP
JOIN dbo.Songs S ON SP.SongID = S.SongID
JOIN dbo.Genre G ON S.GenreID = G.GenreID
JOIN dbo.Location L ON SP.LocationID = L.LocationID
GROUP BY L.Country, G.Name
HAVING COUNT(SP.SongPlayID) = (SELECT MAX(PlayCount)
    FROM (
        SELECT L2.Country, G2.Name AS GenreName, COUNT(SP2.SongPlayID) AS PlayCount
        FROM dbo.SongPlays SP2
        JOIN dbo.Songs S2 ON SP2.SongID = S2.SongID
        JOIN dbo.Genre G2 ON S2.GenreID = G2.GenreID
        JOIN dbo.Location L2 ON SP2.LocationID = L2.LocationID
        GROUP BY L2.Country, G2.Name
    ) AS SubQuery
    WHERE SubQuery.Country = L.Country
)
ORDER BY L.Country, PlayCount DESC;

-- 19 Qual o gênero musical mais ouvido por países, entre as 00AM e as 08AM? 

SELECT L.Country, G.Name AS GenreName, COUNT(SP.SongPlayID) AS PlayCount
FROM dbo.SongPlays SP
JOIN dbo.Songs S ON SP.SongID = S.SongID
JOIN dbo.Genre G ON S.GenreID = G.GenreID
JOIN dbo.Location L ON SP.LocationID = L.LocationID
WHERE CAST(SP.StartTime AS TIME) BETWEEN '00:00:00' AND '08:00:00'
GROUP BY L.Country, G.Name
HAVING COUNT(SP.SongPlayID) = (
    SELECT MAX(PlayCount)
    FROM (
        SELECT L2.Country, G2.Name AS GenreName, COUNT(SP2.SongPlayID) AS PlayCount
        FROM dbo.SongPlays SP2
        JOIN dbo.Songs S2 ON SP2.SongID = S2.SongID
        JOIN dbo.Genre G2 ON S2.GenreID = G2.GenreID
        JOIN dbo.Location L2 ON SP2.LocationID = L2.LocationID
        WHERE CAST(SP2.StartTime AS TIME) BETWEEN '00:00:00' AND '08:00:00'
        GROUP BY L2.Country, G2.Name
    ) AS SubQuery
    WHERE SubQuery.Country = L.Country
)

-- 20 Qual o gênero musical mais ouvido por países, entre as 16:00 e as 24:00? 

SELECT L.Country, G.Name AS GenreName, COUNT(SP.SongPlayID) AS PlayCount
FROM dbo.SongPlays SP
JOIN dbo.Songs S ON SP.SongID = S.SongID
JOIN dbo.Genre G ON S.GenreID = G.GenreID
JOIN dbo.Location L ON SP.LocationID = L.LocationID
WHERE CAST(SP.StartTime AS TIME) BETWEEN '16:00:00' AND '23:59:59'
GROUP BY L.Country, G.Name
HAVING COUNT(SP.SongPlayID) = (
    SELECT MAX(PlayCount)
    FROM (
        SELECT L2.Country, G2.Name AS GenreName, COUNT(SP2.SongPlayID) AS PlayCount
        FROM dbo.SongPlays SP2
        JOIN dbo.Songs S2 ON SP2.SongID = S2.SongID
        JOIN dbo.Genre G2 ON S2.GenreID = G2.GenreID
        JOIN dbo.Location L2 ON SP2.LocationID = L2.LocationID
        WHERE CAST(SP2.StartTime AS TIME) BETWEEN '16:00:00' AND '23:59:59'
        GROUP BY L2.Country, G2.Name
    ) AS SubQuery
    WHERE SubQuery.Country = L.Country
)