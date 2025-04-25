-- Realizar o backup completo da base de dados
BACKUP DATABASE [Music.Streaming]
TO DISK = 'C:\Backups\MusicStreaming_Full.bak'
WITH FORMAT, INIT, NAME = 'Backup Completo da Base de Dados Music.Streaming';

-- Criar um Job para backup agendado
USE msdb;
GO

EXEC sp_add_job
    @job_name = 'BackupJob';

EXEC sp_add_jobstep
    @job_name = 'BackupJob',
    @step_name = 'BackupStep',
    @subsystem = 'TSQL',
    @command = 'BACKUP DATABASE [Music.Streaming] TO DISK = ''C:\Backups\MusicStreaming_Scheduled.bak'' WITH INIT;',
    @on_success_action = 1;

EXEC sp_add_schedule
    @schedule_name = 'WeekdaySchedule',
    @freq_type = 4, -- Daily
    @freq_interval = 1, -- Every day
    @freq_subday_type = 8, -- Hours
    @freq_subday_interval = 6; -- Every 6 hours

EXEC sp_attach_schedule
    @job_name = 'BackupJob',
    @schedule_name = 'WeekdaySchedule';

-- Criar usuários e permissões
-- Criar o usuário CantListen com permissões DENY
CREATE USER CantListen FOR LOGIN CantListenLogin;
DENY SELECT ON DATABASE::[Music.Streaming] TO CantListen;

-- Criar o usuário CanCreatePlaylists com permissões de leitura e escrita
CREATE USER CanCreatePlaylists FOR LOGIN CanCreatePlaylistsLogin;
GRANT SELECT, INSERT, UPDATE, DELETE ON DATABASE::[Music.Streaming] TO CanCreatePlaylists;

-- Criar o usuário SeeDataMaskedUsr com permissões de leitura
CREATE USER SeeDataMaskedUsr FOR LOGIN SeeDataMaskedUsrLogin;
GRANT SELECT ON DATABASE::[Music.Streaming] TO SeeDataMaskedUsr;

--Utilizar DDM (Dynamic Data Masking) NA TABELA UserDM
-- Aplicar Dynamic Data Masking (DDM) na tabela UserDM
ALTER TABLE dbo.UserDM
ALTER COLUMN Nome ADD MASKED WITH (FUNCTION = 'default()');

ALTER TABLE dbo.UserDM
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');

--Criar um JOB que depende de uma Stored Procedure
-- Exemplo de Stored Procedure
CREATE PROCEDURE ListJobsAndSchedules
    @JobName NVARCHAR(100),
    @DataInicial DATETIME,
    @DataFinal DATETIME
AS
BEGIN
    SELECT job.name AS JobName, schedule.name AS ScheduleName, schedule.start_date, schedule.end_date
    FROM msdb.dbo.sysjobs job
    JOIN msdb.dbo.sysjobschedules job_schedule ON job.job_id = job_schedule.job_id
    JOIN msdb.dbo.sysschedules schedule ON job_schedule.schedule_id = schedule.schedule_id
    WHERE job.name = @JobName
      AND schedule.start_date >= @DataInicial
      AND schedule.end_date <= @DataFinal;
END;
GO

