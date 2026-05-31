# Insights de negócio — MusicStreaming Database

Perguntas reais de negócio que a base de dados do MusicStreaming é capaz de responder, com as queries T-SQL correspondentes baseadas no schema real do projeto.

> Contribuição adicionada por **Felipe Guimarães Moraes** após a conclusão do projeto original em equipe.

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

## 1. Quais são as 10 músicas mais reproduzidas?

**Pergunta de negócio:** Quais conteúdos geram mais engajamento na plataforma?

```sql
SELECT TOP 10
    s.Title          AS Musica,
    ar.Name          AS Artista,
    COUNT(sp.SongPlayID) AS TotalReproducoes
FROM dbo.SongPlays sp
JOIN dbo.Songs   s  ON s.SongID   = sp.SongID
JOIN dbo.Artists ar ON ar.ArtistID = s.ArtistID
GROUP BY s.Title, ar.Name
ORDER BY TotalReproducoes DESC;
```

**Por que importa:** base para sistemas de recomendação e decisões de curadoria editorial.

---

## 2. Quais artistas acumulam mais reproduções no total?

**Pergunta de negócio:** Quem são os artistas âncora da plataforma?

```sql
SELECT TOP 10
    ar.Name              AS Artista,
    COUNT(sp.SongPlayID) AS TotalReproducoes,
    COUNT(DISTINCT s.SongID) AS QtdMusicas
FROM dbo.SongPlays sp
JOIN dbo.Songs   s  ON s.SongID    = sp.SongID
JOIN dbo.Artists ar ON ar.ArtistID = s.ArtistID
GROUP BY ar.Name
ORDER BY TotalReproducoes DESC;
```

**Por que importa:** orienta negociações de licenciamento e destaque na plataforma.

---

## 3. Quais gêneros musicais são mais consumidos?

**Pergunta de negócio:** Quais gêneros devem receber mais investimento em catálogo?

```sql
SELECT
    g.Name               AS Genero,
    COUNT(sp.SongPlayID) AS TotalReproducoes,
    COUNT(DISTINCT s.SongID) AS QtdMusicas
FROM dbo.SongPlays sp
JOIN dbo.Songs s ON s.SongID   = sp.SongID
JOIN dbo.Genre g ON g.GenreID  = s.GenreID
GROUP BY g.Name
ORDER BY TotalReproducoes DESC;
```

**Por que importa:** mostra onde concentrar aquisição de novos conteúdos.

---

## 4. Qual o volume de reproduções por mês?

**Pergunta de negócio:** O engajamento está crescendo, estável ou caindo ao longo do tempo?

```sql
SELECT
    YEAR(sp.StartTime)  AS Ano,
    MONTH(sp.StartTime) AS Mes,
    COUNT(sp.SongPlayID) AS TotalReproducoes
FROM dbo.SongPlays sp
GROUP BY YEAR(sp.StartTime), MONTH(sp.StartTime)
ORDER BY Ano, Mes;
```

**Por que importa:** série temporal essencial para análise de tendência e sazonalidade.

---

## 5. Quais países têm mais reproduções?

**Pergunta de negócio:** Onde está concentrada a audiência da plataforma?

```sql
SELECT
    l.Country            AS Pais,
    COUNT(sp.SongPlayID) AS TotalReproducoes,
    COUNT(DISTINCT sp.UserID) AS UsuariosAtivos
FROM dbo.SongPlays sp
JOIN dbo.Location l ON l.LocationID = sp.LocationID
GROUP BY l.Country
ORDER BY TotalReproducoes DESC;
```

**Por que importa:** direciona estratégias de expansão e localização de conteúdo.

---

## 6. Quais álbuns têm a maior média de reproduções por faixa?

**Pergunta de negócio:** Quais álbuns performam bem de forma consistente — não só pelo hit isolado?

```sql
SELECT TOP 10
    al.Name              AS Album,
    ar.Name              AS Artista,
    COUNT(DISTINCT s.SongID)  AS QtdFaixas,
    COUNT(sp.SongPlayID)      AS TotalReproducoes,
    COUNT(sp.SongPlayID) / COUNT(DISTINCT s.SongID) AS MediaPorFaixa
FROM dbo.Albums al
JOIN dbo.Artists  ar ON ar.ArtistID = al.ArtistID
JOIN dbo.Songs    s  ON s.AlbumID   = al.AlbumID
JOIN dbo.SongPlays sp ON sp.SongID  = s.SongID
GROUP BY al.Name, ar.Name
HAVING COUNT(DISTINCT s.SongID) >= 3
ORDER BY MediaPorFaixa DESC;
```

**Por que importa:** identifica álbuns com qualidade uniforme, não só com um single popular.

---

## 7. Quais gravadoras têm mais músicas no catálogo?

**Pergunta de negócio:** Existe concentração de catálogo em poucas gravadoras — um risco para a plataforma?

```sql
SELECT
    lb.Name AS Gravadora,
    COUNT(DISTINCT s.SongID)  AS QtdMusicas,
    COUNT(DISTINCT al.AlbumID) AS QtdAlbuns,
    CAST(
        COUNT(DISTINCT s.SongID) * 100.0
        / SUM(COUNT(DISTINCT s.SongID)) OVER ()
    AS DECIMAL(5,2)) AS PercentualCatalogo
FROM dbo.Labels lb
JOIN dbo.Albums al ON al.LabelID = lb.LabelID
JOIN dbo.Songs  s  ON s.AlbumID  = al.AlbumID
GROUP BY lb.Name
ORDER BY QtdMusicas DESC;
```

**Por que importa:** concentração em poucas gravadoras representa risco contratual e de negócio.

---

## 8. Quantos novos usuários foram cadastrados por mês?

**Pergunta de negócio:** Qual é o ritmo de aquisição de usuários?

```sql
SELECT
    YEAR(u.DateCreated)  AS Ano,
    MONTH(u.DateCreated) AS Mes,
    COUNT(u.UserID)      AS NovosUsuarios
FROM dbo.Users u
GROUP BY YEAR(u.DateCreated), MONTH(u.DateCreated)
ORDER BY Ano, Mes;
```

**Por que importa:** curva de crescimento da base — métrica fundamental para avaliar saúde da plataforma.

---

## 9. Qual o horário de pico de reproduções?

**Pergunta de negócio:** Em que horas do dia os usuários mais consomem música?

```sql
SELECT
    DATEPART(HOUR, sp.StartTime) AS Hora,
    COUNT(sp.SongPlayID)         AS TotalReproducoes
FROM dbo.SongPlays sp
GROUP BY DATEPART(HOUR, sp.StartTime)
ORDER BY TotalReproducoes DESC;
```

**Por que importa:** define janelas ideais para lançamentos, notificações e campanhas de marketing.

---

## 10. Qual a duração média das sessões de escuta por país?

**Pergunta de negócio:** Usuários de quais países passam mais tempo na plataforma?

```sql
SELECT
    l.Country AS Pais,
    COUNT(sp.SongPlayID) AS TotalReproducoes,
    AVG(DATEDIFF(SECOND, sp.StartTime, sp.EndTime)) / 60 AS DuracaoMediaMinutos
FROM dbo.SongPlays sp
JOIN dbo.Location l ON l.LocationID = sp.LocationID
GROUP BY l.Country
ORDER BY DuracaoMediaMinutos DESC;
```

**Por que importa:** tempo de sessão é indicador de engajamento real, não só de cliques.

---

*Schema baseado em `database/01-modelagem/criacao-de-esquema.sql` — SQL Server 2019, T-SQL.*
