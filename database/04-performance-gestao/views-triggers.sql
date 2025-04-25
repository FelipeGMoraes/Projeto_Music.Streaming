--Connverter Stored Procedure parem View
-- Exemplo de conversão de uma Stored Procedure para View
CREATE VIEW View_Example AS
SELECT *
FROM dbo.ExampleTable
WHERE Condition = 'Value';
GO

-- Criar Trigger para LOG
-- Criar tabela de LOG
CREATE TABLE UserLog (
    LogID INT IDENTITY(1,1),
    UserID INT,
    Action NVARCHAR(50),
    ActionDate DATETIME DEFAULT GETDATE()
);

-- Criar Trigger
CREATE TRIGGER UserTableTrigger
ON dbo.Users
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
        INSERT INTO UserLog (UserID, Action)
        SELECT UserID, 'INSERT/UPDATE' FROM inserted;

    IF EXISTS (SELECT * FROM deleted)
        INSERT INTO UserLog (UserID, Action)
        SELECT UserID, 'DELETE' FROM deleted;
END;
GO

