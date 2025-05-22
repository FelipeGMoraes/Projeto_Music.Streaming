-- Realizar o backup completo da base de dados
BACKUP DATABASE [Music.Streaming]
TO DISK = 'C:\Backups\MusicStreaming_Full.bak'
WITH FORMAT, INIT, NAME = 'Backup Full Music.Streaming', 
STATS = 10;
GO


-- Criar um Job para backup agendado
USE msdb;
GO

-- Adicionar o Job
EXEC sp_add_job
    @job_name = 'BackupJob';
GO

-- Adicionar um passo ao Job
EXEC sp_add_jobstep
    @job_name = 'BackupJob',
    @step_name = 'BackupStep',
    @subsystem = 'TSQL',
    @command = 'BACKUP DATABASE [Music.Streaming] TO DISK = ''<CAMINHO_DO_BACKUP>\MusicStreaming_Scheduled.bak'' WITH INIT;',
    @on_success_action = 1;
GO

-- Criar um agendamento para o Job
EXEC sp_add_schedule
    @schedule_name = 'WeekdaySchedule',
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 8,
    @freq_subday_interval = 12; 
GO

-- Associar o agendamento ao Job
EXEC sp_attach_schedule
    @job_name = 'BackupJob',
    @schedule_name = 'WeekdaySchedule';
GO

-- Associar o job ao servidor de jobs padrão
EXEC msdb.dbo.sp_add_jobserver
    @job_name = 'BackupJob',
    @server_name = N'(LOCAL)'; -- Substitua por um nome de servidor específico, se necessário
GO

-- Criar usuários e permissões
-- Criar os logins no servidor (se ainda não existirem)
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'CantListenLogin')
    CREATE LOGIN CantListenLogin WITH PASSWORD = 'StrongPassword123!';
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'CanCreatePlaylistsLogin')
    CREATE LOGIN CanCreatePlaylistsLogin WITH PASSWORD = 'StrongPassword123!';
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'SeeDataMaskedUsrLogin')
    CREATE LOGIN SeeDataMaskedUsrLogin WITH PASSWORD = 'StrongPassword123!';
GO

-- Criar o usuário CantListen com permissões DENY
USE [Music.Streaming];
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'CantListen')
BEGIN
    CREATE USER CantListen FOR LOGIN CantListenLogin;
    DENY SELECT ON DATABASE::[Music.Streaming] TO CantListen;
END;
GO

-- Criar o usuário CanCreatePlaylists com permissões de leitura e escrita
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'CanCreatePlaylists')
BEGIN
    CREATE USER CanCreatePlaylists FOR LOGIN CanCreatePlaylistsLogin;
    GRANT SELECT, INSERT, UPDATE, DELETE ON DATABASE::[Music.Streaming] TO CanCreatePlaylists;
END;
GO

-- Criar o usuário SeeDataMaskedUsr com permissões de leitura
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'SeeDataMaskedUsr')
BEGIN
    CREATE USER SeeDataMaskedUsr FOR LOGIN SeeDataMaskedUsrLogin;
    GRANT SELECT ON DATABASE::[Music.Streaming] TO SeeDataMaskedUsr;
END;
GO

-- Aplicar Dynamic Data Masking (DDM) na tabela UserDM
-- Criar a tabela UserDM se ela não existir
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'UserDM' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.UserDM (
        UserID INT IDENTITY(1,1) PRIMARY KEY,
        Nome NVARCHAR(100),
        Email NVARCHAR(255)
    );
END;
GO

-- Aplicar mascaramento dinâmico
ALTER TABLE dbo.UserDM
ALTER COLUMN Nome ADD MASKED WITH (FUNCTION = 'default()');
GO

ALTER TABLE dbo.UserDM
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');
GO

-- Criar um JOB que depende de uma Stored Procedure
-- Exemplo de Stored Procedure
CREATE PROCEDURE ListJobsAndSchedules
    @JobName NVARCHAR(100),
    @DataInicial DATETIME,
    @DataFinal DATETIME
AS
BEGIN
    SELECT 
        job.name AS JobName, 
        schedule.name AS ScheduleName, 
        CAST(CONVERT(DATETIME, CAST(schedule.active_start_date AS CHAR(8)), 112) AS DATETIME) AS StartDate, 
        CAST(CONVERT(DATETIME, CAST(schedule.active_end_date AS CHAR(8)), 112) AS DATETIME) AS EndDate,
        schedule.active_start_time AS StartTime,
        schedule.active_end_time AS EndTime
    FROM msdb.dbo.sysjobs job
    JOIN msdb.dbo.sysjobschedules job_schedule ON job.job_id = job_schedule.job_id
    JOIN msdb.dbo.sysschedules schedule ON job_schedule.schedule_id = schedule.schedule_id
    WHERE job.name = @JobName
      AND CAST(CONVERT(DATETIME, CAST(schedule.active_start_date AS CHAR(8)), 112) AS DATETIME) >= @DataInicial
      AND CAST(CONVERT(DATETIME, CAST(schedule.active_end_date AS CHAR(8)), 112) AS DATETIME) <= @DataFinal;
END;
GO