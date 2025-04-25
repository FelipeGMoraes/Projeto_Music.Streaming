-- Criar Filegroyups e Datafiles
-- Criar Filegroup
ALTER DATABASE [Music.Streaming]
ADD FILEGROUP FileGroup1;

-- Adicionar Datafile
ALTER DATABASE [Music.Streaming]
ADD FILE (
    NAME = 'File1',
    FILENAME = 'C:\Data\File1.ndf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
) TO FILEGROUP FileGroup1;
GO

-- Verifgicar Integridade da base de dados
DBCC CHECKDB([Music.Streaming]);
GO

-- Verificar variáveis do tipo @table
DECLARE @TempTable TABLE (
    ID INT,
    Name NVARCHAR(50)
);

INSERT INTO @TempTable (ID, Name)
VALUES (1, 'Example');

SELECT * FROM @TempTable;
GO

-- Utilizar tabelas temporárias
CREATE TABLE #TempTable (
    ID INT,
    Name NVARCHAR(50)
);

INSERT INTO #TempTable (ID, Name)
VALUES (1, 'Example');

SELECT * FROM #TempTable;

DROP TABLE #TempTable;
GO

-- Particionar e comprimir tabelas
-- Particionar tabela
CREATE PARTITION FUNCTION PartitionFunction (INT)
AS RANGE LEFT FOR VALUES (100, 200, 300);

CREATE PARTITION SCHEME PartitionScheme
AS PARTITION PartitionFunction
ALL TO ([PRIMARY]);

-- Comprimir tabela
ALTER TABLE dbo.Sessions
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = PAGE);
GO