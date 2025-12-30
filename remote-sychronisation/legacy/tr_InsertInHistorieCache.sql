USE [Apobase]
GO

/****** Object:  Trigger [dbo].[InsertInHistorieCache]    Script Date: 11.07.2025 18:05:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[InsertInHistorieCache] ON [dbo].[RW_APOBASE_Historie]
	AFTER UPDATE
AS 
BEGIN

	IF UPDATE(strVerbund)
	OR UPDATE(dtLzAustausch)
	OR UPDATE(diLfdNrHistorieVerbund)	
	BEGIN 
		DECLARE @nothing INT
		SET @nothing=0
	END 

	ELSE
	BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    	DECLARE @InCache INT							--Variable zur Prüfung, ob KdNr schon im Cache liegt
		DECLARE @diKdNr INT								--Variable um die KdNr, um die es geht, abzulegen

		DECLARE Inserted_Cursor CURSOR FOR							--Cursor erstellen zum Durchlaufen
			SELECT ISNULL(i.diLfdNr,0) FROM inserted i		--Herausfinden, um welche KdNr es überhaupt geht

		OPEN Inserted_Cursor 

		FETCH NEXT FROM Inserted_Cursor INTO @diKdNr

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--Anzahl Datensätze holen, die im Cache schon die KdNr haben
			SELECT @InCache = SumCount FROM  (SELECT COUNT(*) AS SumCount FROM RW_MODUL_VerbundCacheHistorie WHERE diLfdNr = @diKdNr) t1
		
			IF (@InCache = 0)	
			BEGIN
				IF @diKdNr <> 0 
					INSERT INTO RW_MODUL_VerbundCacheHistorie (diLfdNr, dtDatum) VALUES (@diKdNr, CURRENT_TIMESTAMP)
			END	
			ELSE
			BEGIN
				UPDATE RW_MODUL_VerbundCacheHistorie SET dtDatum = CURRENT_TIMESTAMP WHERE diLfdNr = @diKdNr
			END
			
			FETCH NEXT FROM Inserted_Cursor INTO @diKdNr
		END
		CLOSE Inserted_Cursor
		DEALLOCATE Inserted_Cursor
	END
END
GO

ALTER TABLE [dbo].[RW_APOBASE_Historie] ENABLE TRIGGER [InsertInHistorieCache]
GO


