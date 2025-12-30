USE [Apobase]
GO

/****** Object:  Trigger [dbo].[InsertInCache]    Script Date: 11.07.2025 18:04:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[InsertInCache] ON [dbo].[RW_APOBASE_Kunde]
AFTER UPDATE
AS
BEGIN

	IF UPDATE(diKdNr)
	OR UPDATE(strIdent)
	OR UPDATE(diUmsLJ)
	OR UPDATE(diUmsVJ)
	OR UPDATE(diKontakteLJ)
	OR UPDATE(diKontakteVJ)
	OR UPDATE(strSuchName)
	OR UPDATE(diZZLJ)
	OR UPDATE(diErtragLJ)
	OR UPDATE(diErtragVJ)
	OR UPDATE(diBGAPartner)
	OR UPDATE(diBonusBetragLJ)
	OR UPDATE(diBonusBetragVJ)
	OR UPDATE(diBonusPunkteLJ)
	OR UPDATE(diBonusPunkteVJ)
	OR UPDATE(diBonusUmsLJRzptPfl)
	OR UPDATE(diBonusUmsVJRzptPfl)
	OR UPDATE(diBonusUmsLJApoPfl)
	OR UPDATE(diBonusUmsVJApoPfl)
	OR UPDATE(diBonusUmsLJFreiwahl)
	OR UPDATE(diBonusUmsVJFreiwahl)
	OR UPDATE(diBonusUmsLJSonstige)
	OR UPDATE(diBonusUmsVJSonstige)
	OR UPDATE(diBonusUmsLJGKVZahlbetrag)
	OR UPDATE(diBonusUmsVJGKVZahlbetrag)
	BEGIN 
	RETURN
	END 

	DECLARE @InCache INT							--Variable zur Prüfung, ob KdNr schon im Cache liegt
	DECLARE @diKdNr INT								--Variable um die KdNr, um die es geht, abzulegen

	DECLARE Inserted_Cursor CURSOR FOR							--Cursor erstellen zum Durchlaufen
		SELECT ISNULL(i.diKdNrAuto,0) FROM inserted i		--Herausfinden, um welche KdNr es überhaupt geht

	OPEN Inserted_Cursor 

	FETCH NEXT FROM Inserted_Cursor INTO @diKdNr

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Anzahl Datensätze holen, die im Cache schon die KdNr haben
		SELECT @InCache = SumCount FROM  (SELECT COUNT(*) AS SumCount FROM RW_MODUL_VerbundCacheKunde WHERE diKdNr = @diKdNr) t1
		
		IF (@InCache = 0)	
		BEGIN
			IF @diKdNr <> 0 
				INSERT INTO RW_MODUL_VerbundCacheKunde (diKdNr, dtDatum) VALUES (@diKdNr, CURRENT_TIMESTAMP)
		END	
		ELSE
		BEGIN
			UPDATE RW_MODUL_VerbundCacheKunde SET dtDatum = CURRENT_TIMESTAMP WHERE diKdNr = @diKdNr
		END
			
		FETCH NEXT FROM Inserted_Cursor INTO @diKdNr
	END
	CLOSE Inserted_Cursor
	DEALLOCATE Inserted_Cursor

END
GO

ALTER TABLE [dbo].[RW_APOBASE_Kunde] ENABLE TRIGGER [InsertInCache]
GO


