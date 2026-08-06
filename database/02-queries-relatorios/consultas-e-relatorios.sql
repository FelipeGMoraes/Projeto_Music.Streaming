# Consultas e Relatórios — MusicStreaming Database

Coleção de consultas e relatórios prontos para análise sobre o schema do MusicStreaming. As queries abaixo são organizadas por objetivo analítico e apresentadas em blocos T-SQL prontos para execução.

---

## Tabelas do schema

| Tabela | Descrição |
|---|---|
| `dbo.Songs` | Músicas (título, duração, data de lançamento) |
| `dbo.SongPlays` | Reproduções (quem ouviu, quando, onde) |
| `dbo.Artists` | Artistas |
| `dbo.Albums` | Álbuns |
| `dbo.Genre` | Gêneros musicais |
| `dbo.Users` | Usuários da plataforma |
| `dbo.Labels` | Gravadoras |
| `dbo.Location` | Localizações (país, fuso horário) |

---

## 1. Lista alfabética de utilizadores

**Pergunta de negócio:** Retorna todos os usuários ordenados por nome e sobrenome.

```sql
SELECT DISTINCT FirstName, LastName
FROM dbo.Users
ORDER BY FirstName, LastName;
```

---

## 2. Lista alfabética de gêneros musicais

**Pergunta de negócio:** Exibir todos os gêneros cadastrados na plataforma.

```sql
SELECT Name AS Genre
FROM dbo.Genre
ORDER BY Name;
```

---

## 3. Lista alfabética de gravadoras

**Pergunta de negócio:** Exibir todas as gravadoras do catálogo.

```sql
SELECT Name AS Label
FROM dbo.Labels
ORDER BY Name;
```

---

## 4. Artistas por país

**Pergunta de negócio:** Quais artistas existem por país de origem?

```sql
SELECT A.Name AS Artist, L.Country
FROM dbo.Artists A
JOIN dbo.Location L ON A.LocationID = L.LocationID
ORDER BY L.Country, A.Name;
```

---

## 5. Catálogo: artista, gravadora, gênero, álbum

**Pergunta de negócio:** Como relacionar artista, gravadora, gênero e álbum para relatórios de catálogo?

```sql
SELECT A.Name AS Artist, L.Name AS LabelName, G.Name AS GenreName, Al.Name AS AlbumName
FROM dbo.Albums Al
JOIN dbo.Artists A ON Al.ArtistID = A.ArtistID
JOIN dbo.Labels L ON Al.LabelID = L.LabelID
JOIN dbo.Songs S ON Al.AlbumID = S.AlbumID
JOIN dbo.Genre G ON S.GenreID = G.GenreID
GROUP BY A.Name, L.Name, G.Name, Al.Name
ORDER BY Artist, LabelName, GenreName, AlbumName;
```

---

## 6. Top 5 países com mais artistas

**Pergunta de negócio:** Quais países concentram mais artistas cadastrados?

```sql
SELECT TOP 5 L.Country, COUNT(A.ArtistID) AS BandCount
FROM dbo.Artists A
JOIN dbo.Location L ON A.LocationID = L.LocationID
GROUP BY L.Country
ORDER BY BandCount DESC;
```

---

## 7. Top 10 artistas com mais álbuns

**Pergunta de negócio:** Quais artistas têm maior quantidade de álbuns no catálogo?

```sql
SELECT TOP 10 A.Name AS Artist, COUNT(Al.AlbumID) AS AlbumCount
FROM dbo.Albums Al
JOIN dbo.Artists A ON Al.ArtistID = A.ArtistID
GROUP BY A.Name
ORDER BY AlbumCount DESC;
```

---

## 8. Top 5 gravadoras com mais álbuns

**Pergunta de negócio:** Quais gravadoras disponibilizam mais álbuns?

```sql
SELECT TOP 5 L.Name AS LabelName, COUNT(Al.AlbumID) AS AlbumCount
FROM dbo.Albums Al
JOIN dbo.Labels L ON Al.LabelID = L.LabelID
GROUP BY L.Name
ORDER BY AlbumCount DESC;
```

---

## 9. Top 5 gêneros com mais álbuns

**Pergunta de negócio:** Quais gêneros têm maior número de álbuns?

```sql
SELECT TOP 5 G.Name AS GenreName, COUNT(S.AlbumID) AS AlbumCount
FROM dbo.Songs S
JOIN dbo.Genre G ON S.GenreID = G.GenreID
GROUP BY G.Name
ORDER BY AlbumCount DESC;
```

---

## 10. Top 20 músicas mais longas

**Pergunta de negócio:** Quais faixas têm maior duração?

```sql
SELECT TOP 20 S.Title AS SongTitle, S.Duration
FROM dbo.Songs S
ORDER BY S.Duration DESC;
```

---

## 11. Top 20 músicas mais curtas

**Pergunta de negócio:** Quais faixas têm menor duração?

```sql
SELECT TOP 20 S.Title AS SongTitle, S.Duration
FROM dbo.Songs S
ORDER BY S.Duration ASC;
```

---

## 12. Top 10 álbuns com maior duração total

**Pergunta de negócio:** Quais álbuns têm a maior soma de durações das faixas?

```sql
SELECT TOP 10 Al.Name AS AlbumName, SUM(DATEDIFF(SECOND, '00:00:00', S.Duration)) AS DuracaoTotalEmSegundos
FROM dbo.Songs S
JOIN dbo.Albums Al ON S.AlbumID = Al.AlbumID
GROUP BY Al.Name
ORDER BY DuracaoTotalEmSegundos DESC;
```

---

## 13. Quantidade de músicas por álbum

**Pergunta de negócio:** Quantas faixas existem em cada álbum?

```sql
SELECT Al.Name AS AlbumName, COUNT(S.SongID) AS SongCount
FROM dbo.Songs S
JOIN dbo.Albums Al ON S.AlbumID = Al.AlbumID
GROUP BY Al.Name
ORDER BY SongCount DESC;
```

---

## 14. Quantas músicas têm mais de 5 minutos

**Pergunta de negócio:** Quantas faixas excedem 5 minutos de duração?

```sql
SELECT COUNT(S.SongID) AS SongsOver5Min
FROM dbo.Songs S
WHERE S.Duration > '00:05:00';
```

---

## 15. Músicas mais ouvidas

**Pergunta de negócio:** Quais músicas têm mais reproduções no total?

```sql
SELECT S.Title AS SongTitle, COUNT(SP.SongPlayID) AS PlayCount
FROM dbo.SongPlays SP
JOIN dbo.Songs S ON SP.SongID = S.SongID
GROUP BY S.Title
ORDER BY PlayCount DESC;
```

---

## 16. Músicas mais ouvidas por país entre (00:00–08:00)

**Pergunta de negócio:** Quais faixas lideram pela manhã em cada país?

```sql
SELECT S.Title AS SongTitle, L.Country, COUNT(SP.SongPlayID) AS PlayCount
FROM dbo.SongPlays SP
JOIN dbo.Songs S ON SP.SongID = S.SongID
JOIN dbo.Location L ON SP.LocationID = L.LocationID
WHERE CAST(SP.StartTime AS TIME) BETWEEN '00:00:00' AND '08:00:00'
GROUP BY S.Title, L.Country
ORDER BY L.Country, PlayCount DESC;
```

---

## 17. Músicas mais ouvidas por país entre (08:00–16:00)

**Pergunta de negócio:** Quais faixas lideram durante o dia em cada país?

```sql
SELECT S.Title AS SongTitle, L.Country, COUNT(SP.SongPlayID) AS PlayCount
FROM dbo.SongPlays SP
JOIN dbo.Songs S ON SP.SongID = S.SongID
JOIN dbo.Location L ON SP.LocationID = L.LocationID
WHERE CAST(SP.StartTime AS TIME) BETWEEN '08:00:00' AND '16:00:00'
GROUP BY S.Title, L.Country
ORDER BY L.Country, PlayCount DESC;
```

---

## 18. Gênero mais ouvido por país

**Pergunta de negócio:** Qual gênero domina o consumo em cada país?

```sql
SELECT L.Country, G.Name AS GenreName, COUNT(SP.SongPlayID) AS PlayCount
FROM dbo.SongPlays SP
JOIN dbo.Songs S ON SP.SongID = S.SongID
JOIN dbo.Genre G ON S.GenreID = G.GenreID
JOIN dbo.Location L ON SP.LocationID = L.LocationID
GROUP BY L.Country, G.Name
HAVING COUNT(SP.SongPlayID) = (
    SELECT MAX(PlayCount)
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
```

---

## 19. Gênero mais ouvido por país entre (00:00–08:00)

**Pergunta de negócio:** Qual gênero predomina nas horas da madrugada/matutino em cada país?

```sql
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
);
```

---

## 20. Gênero mais ouvido por país (16:00–23:59)

**Pergunta de negócio:** Qual gênero predomina no fim do dia em cada país?

```sql
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
);
```

---

*Schema baseado em `database/01-modelagem/criacao-de-esquema.sql` — SQL Server 2019, T-SQL.*