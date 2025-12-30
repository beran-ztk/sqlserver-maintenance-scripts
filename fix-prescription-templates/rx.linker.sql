-- Datensatz anpassen -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @ERezeptID NVARCHAR(MAX) = '0000000000';																																																			IF(LEN(@ERezeptID) = 17) SET @ERezeptID = SUBSTRING(CONVERT(nvarchar(25), @ERezeptID),0,4)+'.'+SUBSTRING(CONVERT(nvarchar(25), @ERezeptID),4,3)+'.'+SUBSTRING(CONVERT(nvarchar(25), @ERezeptID),7,3)+'.'+SUBSTRING(CONVERT(nvarchar(25), @ERezeptID),10,3)+'.'+ SUBSTRING(CONVERT(nvarchar(25), @ERezeptID),13,3)+'.'+SUBSTRING(CONVERT(nvarchar(25), @ERezeptID),16,2)
DECLARE @Blob NVARCHAR(MAX) = '';

DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID = @ERezeptID;
UPDATE RW_EREZEPT_Abrechnung SET Blob = @Blob WHERE ERezeptID = @ERezeptID;
UPDATE RW_APOBASE_Rezept SET cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID = @ERezeptID;
RETURN;

-- Abgabe ändern -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC Abgabetausch @ERezeptID = '0000', @Vorgangsnummer = 0000, @DatumVorgang = 0000, @Charge = '0000'; 
-- COMMIT; ROLLBACK; 

-- Daten ermitteln -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT ERezeptID,* FROM RW_APOBASE_Rezept	 WHERE ERezeptID LIKE '%0000';
SELECT ERezeptID,* FROM RW_APOBASE_Rezept	 WHERE didate = 0000 AND iRpNr = 0000;
SELECT *		   FROM RW_APOBASE_Vorgaenge WHERE didate = 0000 AND (ivgnr = NULL OR iRpNr = NULL);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
