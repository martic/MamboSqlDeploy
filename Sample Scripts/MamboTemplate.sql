USE [AdventureWorksDWMamboSample]

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[script_version]') AND type in (N'U'))
BEGIN

	CREATE TABLE dbo.script_version
		(
		script_id smallint NOT NULL IDENTITY (1, 1),
		script_name varchar(200) NULL
		)  ON [PRIMARY]

	ALTER TABLE dbo.script_version ADD CONSTRAINT
		PK_script_version PRIMARY KEY CLUSTERED 
		(
		script_id
		) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

END

BEGIN TRANSACTION
DECLARE @Outcome_Message nvarchar(4000)
SET @Outcome_Message = 'Database is up to date.'

BEGIN TRY

[BEGIN LOOP]

IF NOT EXISTS (SELECT * FROM dbo.script_version WHERE script_name = '[INSERT FILENAME];[INSERT SECTION NUMBER]') 
BEGIN
	
	EXECUTE('[INSERT FILE]')

	SET NOCOUNT ON
	INSERT INTO dbo.script_version VALUES ('[INSERT FILENAME];[INSERT SECTION NUMBER]')

	SET @Outcome_Message = 'Succesfully upgraded database through script ''[INSERT FILENAME]''.'

END

[END LOOP]

PRINT @Outcome_Message

END TRY
BEGIN CATCH
	DECLARE @Error_Message NVARCHAR(4000)
	SET @Error_Message = 'ERROR:  An error was encountered during the upgrade.  All changes have been rolled back.' + CHAR(13) + ERROR_MESSAGE()
	ROLLBACK WORK
	RAISERROR (@Error_Message, 10, 1, '')
END CATCH;	

IF @@TRANCOUNT > 0 COMMIT WORK