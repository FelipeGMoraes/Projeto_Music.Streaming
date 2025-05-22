-- Criar uma Procedure para mensagens de erro
CREATE PROCEDURE GetErrorMessage
    @Severity INT,
    @MessageID INT,
    @LanguageID INT
AS
BEGIN
    -- Verifica se a severidade é válida
    SELECT severity, text
    FROM sys.messages
    WHERE severity = @Severity
      AND message_id = @MessageID
      AND language_id = @LanguageID;
END;
GO

-- Para executar a Procedure (exemplo):
EXEC GetErrorMessage 
    @Severity = 16, 
    @MessageID = 547, 
    @LanguageID = 1033;

-- Realizar uma análise de vulnerabilidades (Vulnerability Assessment Report - VAR)
-- Este processo ajuda a identificar possíveis vulnerabilidades de segurança no banco de dados.
-- As etapas abaixo são realizadas no SQL Server Management Studio (SSMS):
1. Acesse o menu Security > Vulnerability Assessment no banco de dados desejado.
2. Clique em "Scan for Vulnerabilities" para iniciar a análise.
3. Salve o relatório gerado para revisão e implementação de melhorias de segurança.

-- Encriptar a base de dados com TDE (Transparent Data Encryption)
-- Habilitar Transparent Data Encryption (TDE)
USE master;
GO
-- Criar uma chave mestra para criptografia
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'StrongPassword123!';
GO
-- Criar um certificado para TDE
CREATE CERTIFICATE TDECert WITH SUBJECT = 'TDE Certificate';
GO
-- Configurar a base de dados para usar TDE
USE [Music.Streaming];
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256 -- Algoritmo de criptografia
ENCRYPTION BY SERVER CERTIFICATE TDECert;
GO
-- Ativar a criptografia na base de dados
ALTER DATABASE [Music.Streaming] SET ENCRYPTION ON;
GO