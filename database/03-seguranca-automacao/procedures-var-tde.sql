-- Procedure para buscar mensagens de erro do SQL Server
CREATE PROCEDURE GetErrorMessage
    @Severity INT,
    @MessageID INT,
    @LanguageID INT
AS
BEGIN
    -- Busca mensagem de erro personalizada conforme parâmetros
    SELECT severity, text
    FROM sys.messages
    WHERE severity = @Severity
      AND message_id = @MessageID
      AND language_id = @LanguageID;
END;
GO

-- Exemplo de execução da procedure:
-- EXEC GetErrorMessage @Severity = 16, @MessageID = 547, @LanguageID = 1033;

-- Análise de Vulnerabilidades (Vulnerability Assessment Report - VAR)
-- Ajuda a identificar possíveis vulnerabilidades de segurança no banco de dados.
-- Etapas (executadas via SSMS):
-- 1. Menu Security > Vulnerability Assessment no banco desejado.
-- 2. Clique em "Scan for Vulnerabilities" para iniciar.
-- 3. Salve o relatório para revisão e implementação de melhorias.

-- Transparent Data Encryption (TDE) para criptografia da base
-- ATENÇÃO: Nunca versionar senhas reais. Use variáveis de ambiente ou placeholders em produção.
USE master;
GO
-- Criação de chave mestra para criptografia
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'StrongPassword123!'; -- Substitua por senha forte e segura
GO
-- Criação de certificado para TDE
CREATE CERTIFICATE TDECert WITH SUBJECT = 'TDE Certificate';
GO
-- Configurar a base para usar TDE
USE [Music.Streaming];
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256 -- Algoritmo de criptografia
ENCRYPTION BY SERVER CERTIFICATE TDECert;
GO
-- Ativar criptografia na base
ALTER DATABASE [Music.Streaming] SET ENCRYPTION ON;
GO