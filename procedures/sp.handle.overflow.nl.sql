USE [Apobase]
GO

SET XACT_ABORT ON;

BEGIN TRY
	BEGIN TRANSACTION
		IF EXISTS (
			SELECT 1
			FROM sys.foreign_keys
			WHERE name = 'FK_RW_APOBASE_Nachlieferung_RW_APOBASE_NachlieferungInfo'
			AND parent_object_id = OBJECT_ID(N'[dbo].[RW_APOBASE_Nachlieferung]')
		)
		BEGIN
			ALTER TABLE [dbo].[RW_APOBASE_Nachlieferung]
			DROP CONSTRAINT [FK_RW_APOBASE_Nachlieferung_RW_APOBASE_NachlieferungInfo];
		END

		UPDATE [dbo].[RW_APOBASE_NachlieferungInfo]
		SET [iNlNr] = RIGHT([iNlNr], 3);

		UPDATE [dbo].[RW_APOBASE_Nachlieferung]
		SET [iVgNr] = RIGHT([iVgNr], 3);

		ALTER TABLE [dbo].[RW_APOBASE_Nachlieferung]  
		WITH CHECK ADD CONSTRAINT [FK_RW_APOBASE_Nachlieferung_RW_APOBASE_NachlieferungInfo] 
			FOREIGN KEY([iVgNr])
			REFERENCES [dbo].[RW_APOBASE_NachlieferungInfo] ([iNlNr])
			ON DELETE CASCADE;

		DECLARE @Orphans INT;
		SELECT @Orphans = COUNT(*)
		FROM [dbo].[RW_APOBASE_NachlieferungInfo] i
		WHERE NOT EXISTS (
			SELECT 1
			FROM [dbo].[RW_APOBASE_Nachlieferung] n
			WHERE n.[iVgNr] = i.[iNlNr]
		);

		IF @Orphans > 0
		BEGIN
			THROW 51000, 'Es existieren verwaiste Einträge in RW_APOBASE_NachlieferungInfo.', 1;
		END

	COMMIT TRANSACTION;
    	PRINT 'Alle Änderungen erfolgreich. Transaction committed.';
END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION;

	DECLARE 
		@ErrMessage NVARCHAR(MAX) = ERROR_MESSAGE(),
		@ErrSeverity INT = ERROR_SEVERITY(),
		@ErrState INT = ERROR_STATE();

	RAISERROR('FEHLER: %s', @ErrSeverity, @ErrState, @ErrMessage);
END CATCH;
GO
