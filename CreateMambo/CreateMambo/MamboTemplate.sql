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

	PRINT 'ScriptVersionBaselineTables.sql successfully applied.'

END
ELSE
BEGIN
	PRINT 'WARNING:  ScriptVersionBaselineTables.sql already applied.'
END
GO

-- ************************************* NEXT FILE ************************************* 
[BEGIN LOOP]

IF NOT EXISTS (SELECT * FROM dbo.script_version WHERE script_name = '[INSERT FILENAME]') 
BEGIN
	
	[INSERT FILE]

	SET NOCOUNT ON
	INSERT INTO dbo.script_version VALUES ('[INSERT FILENAME]')

	PRINT '[INSERT FILENAME] successfully applied.'	

END
ELSE
BEGIN
	PRINT 'WARNING:  [INSERT FILENAME] already applied.'
END

GO
-- ************************************* NEXT FILE ************************************* 
[END LOOP]