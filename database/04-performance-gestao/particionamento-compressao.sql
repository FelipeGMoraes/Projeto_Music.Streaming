-- Criar Filegroup e Datafile
USE [Music.Streaming]
GO

-- Criar um novo Filegroup para os dados particionados da SongPlays
ALTER DATABASE [Music.Streaming]
ADD FILEGROUP SongPlaysFG;
GO

-- Adicionar Datafile ao novo Filegroup
ALTER DATABASE [Music.Streaming]
ADD FILE (
    NAME = 'SongPlaysData01',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Data\SongPlaysData01.ndf',
	SIZE = 100MB,
    MAXSIZE = 1GB,
    FILEGROWTH = 100MB
) TO FILEGROUP SongPlaysFG;
GO

-- Verificar integridade da base de dados
-- É uma boa prática executar isso regularmente, especialmente antes/depois de grandes alterações.
DBCC CHECKDB([Music.Streaming]);
GO

-- Particionar Tabela (dbo.SongPlays por StartTime)

IF NOT EXISTS (SELECT * FROM sys.partition_functions WHERE name = 'PF_SongPlays_ByStartTime_Annual')
BEGIN
    CREATE PARTITION FUNCTION PF_SongPlays_ByStartTime_Annual (DATETIME)
    AS RANGE RIGHT FOR VALUES (
        '2010-01-01T00:00:00',
		'2015-01-01T00:00:00',
        '2020-01-01T00:00:00' 
    );
    PRINT 'Função de Partição PF_SongPlays_ByStartTime_Annual criada.';
END
ELSE
BEGIN
    PRINT 'Função de Partição PF_SongPlays_ByStartTime_Annual já existe.';
END
GO

-- Criar Esquema de Partição

IF NOT EXISTS (SELECT * FROM sys.partition_schemes WHERE name = 'PS_SongPlays_ByStartTime_Annual')
BEGIN
    CREATE PARTITION SCHEME PS_SongPlays_ByStartTime_Annual
    AS PARTITION PF_SongPlays_ByStartTime_Annual
    ALL TO (SongPlaysFG);
    PRINT 'Esquema de Partição PS_SongPlays_ByStartTime_Annual criado.';
END
ELSE
BEGIN
    PRINT 'Esquema de Partição PS_SongPlays_ByStartTime_Annual já existe.';
END
GO

-- Aplicar o Particionamento à Tabela dbo.SongPlays


-- Remove a constraint PK existente se ela for o índice clusterizado.
-- A PK original é em SongPlayID.
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SongPlays') AND name = 'PK_SongsPlays_SongPlayID' AND type_desc = 'CLUSTERED')
BEGIN
    ALTER TABLE dbo.SongPlays
    DROP CONSTRAINT PK_SongsPlays;
    PRINT 'Constraint PK_SongsPlays_SongPlayID (CLUSTERED) removida.';
END
ELSE
BEGIN
    PRINT 'Constraint PK_SongsPlays_SongPlayID (CLUSTERED) não encontrada ou não é clusterizada.';
END
GO

-- Cria o novo Índice Clusterizado na coluna de partição (StartTime) e na antiga PK (SongPlayID)
-- A coluna de partição (StartTime) deve vir primeiro ou estar incluída na chave do índice clusterizado.
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SongPlays') AND name = 'CX_SongPlays_StartTime_SongPlayID')
BEGIN
    CREATE CLUSTERED INDEX CX_SongPlays_StartTime_SongPlayID
    ON dbo.SongPlays (StartTime ASC, SongPlayID ASC) -- Coluna de partição primeiro
    ON PS_SongPlays_ByStartTime_Annual(StartTime); -- Aplicando o esquema de partição na coluna StartTime
    PRINT 'Índice Clusterizado CX_SongPlays_StartTime_SongPlayID criado no esquema de partição.';
END
ELSE
BEGIN
    PRINT 'Índice Clusterizado CX_SongPlays_StartTime_SongPlayID já existe.';
END
GO

-- Recria a Chave Primária original como NÃO CLUSTERIZADA, se necessário.
-- Isso mantém a unicidade de SongPlayID.
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE object_id = OBJECT_ID('dbo.PK_SongPlays_SongPlayID_NC') AND type = 'PK')
BEGIN
    ALTER TABLE dbo.SongPlays
    ADD CONSTRAINT PK_SongPlays_SongPlayID_NC
    PRIMARY KEY NONCLUSTERED (SongPlayID ASC)
    ON [PRIMARY]; -- Ou no filegroup que preferir para a PK não clusterizada
    PRINT 'Constraint PK_SongPlays_SongPlayID_NC (NONCLUSTERED) recriada.';
END
ELSE
BEGIN
    PRINT 'Constraint PK_SongPlays_SongPlayID_NC (NONCLUSTERED) já existe.';
END
GO

-- Comprimir Tabela Particionada
ALTER TABLE dbo.SongPlays
REBUILD PARTITION = ALL
WITH (
    DATA_COMPRESSION = PAGE -- Ou ROW
);
PRINT 'Tabela dbo.SongPlays reconstruída com compressão de dados (PAGE).';
GO

-- Para verificar as partições e suas informações:

SELECT p.partition_number AS PartitionNumber, fg.name AS FileGroupName,
    pf.name AS PartitionFunctionName, ps.name AS PartitionSchemeName,
    prv.value AS PartitionBoundaryValue, p.rows AS RowsInPartition
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.data_spaces ds ON i.data_space_id = ds.data_space_id
INNER JOIN sys.partition_schemes ps ON ds.data_space_id = ps.data_space_id
INNER JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
LEFT JOIN sys.partition_range_values prv ON pf.function_id = prv.function_id AND p.partition_number = (CASE WHEN pf.boundary_value_on_right = 0 THEN prv.boundary_id + 1 ELSE prv.boundary_id END)
LEFT JOIN sys.destination_data_spaces dds ON ps.data_space_id = dds.partition_scheme_id AND p.partition_number = dds.destination_id
LEFT JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id OR i.data_space_id = fg.data_space_id AND dds.data_space_id IS NULL AND fg.type = 'FG'
WHERE o.name = 'SongPlays' AND i.type_desc IN ('CLUSTERED', 'HEAP')
ORDER BY p.partition_number;
GO

