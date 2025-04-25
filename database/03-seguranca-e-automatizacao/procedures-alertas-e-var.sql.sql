-- Criar uma Procedure para mensagens de erro
CREATE PROCEDURE GetErrorMessage
    @Severity INT,
    @MessageID INT,
    @LanguageID INT
AS
BEGIN
    SELECT severity, text
    FROM sys.messages
    WHERE severity = @Severity
      AND message_id = @MessageID
      AND language_id = @LanguageID;
END;
GO

-- Criar alertas do tipo Event Alert
-- Criar alertas de eventos de 17 a 25
DECLARE @i INT = 17;
WHILE @i <= 25
BEGIN
    EXEC msdb.dbo.sp_add_alert
        @name = 'EventAlert_' + CAST(@i AS NVARCHAR(10)),
        @message_id = @i,
        @severity = 0,
        @enabled = 1;
    SET @i = @i + 1;
END;
GO

-- Efetuar um Vunerability Assessment Report (VAR)
3/2 - Efetuar um Vulnerability Assessment Report (VAR)
No SQL Server Management Studio (SSMS), vá para Security > Vulnerability Assessment.
Clique em Scan for Vulnerabilities.
Salve o relatório gerado.

-- Encriptar a base de dados com TDE (Transparent Data Encryption)
-- Habilitar Transparent Data Encryption (TDE)
USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'StrongPassword123!';
GO
CREATE CERTIFICATE TDECert WITH SUBJECT = 'TDE Certificate';
GO
USE [Music.Streaming];
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDECert;
GO
ALTER DATABASE [Music.Streaming] SET ENCRYPTION ON;