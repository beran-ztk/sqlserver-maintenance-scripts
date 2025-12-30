	USE APOBASE;
	GO

	SET ANSI_NULLS ON
	GO

	SET QUOTED_IDENTIFIER ON
	GO

	IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Zuweisung')
	DROP PROCEDURE Zuweisung
	GO

	CREATE PROCEDURE [dbo].[Zuweisung] (@ERezeptID NVARCHAR(30), @Vorgangsnummer INT, @DatumVorgang INT, @Charge NVARCHAR(30))

	AS 
	BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRANSACTION;
	

--******************************************************************************************Variablen************************************************************************************************************************************************************************************-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @RpNrNeu INT,@RpLfdNeu INT, @ROWCOUNT INT, @PznERezept INT, @PznVorgang INT, @RpNrERezept INT, @DatumErezept INT, @LfdVG INT;
	
    -- PZN vom ERezept
	SET @PznERezept = (SELECT TOP 1 dipzn FROM rw_apobase_rezept WHERE erezeptid = @ERezeptID AND NOT dipzn IN (2567024,6461110,9999175,9999005,9999057));

	-- Datum vom ERezept
	SET @DatumErezept = (SELECT TOP 1 didate FROM rw_apobase_rezept WHERE ERezeptID = @ERezeptID AND diPzn = @PznERezept);
	
	-- Datum anpassen
	IF (@DatumVorgang = 0000) BEGIN SET @DatumVorgang = @DatumErezept;END
		
	-- Rezeptnummer vom ERezept
	SET @RpNrERezept = (SELECT TOP 1 irpnr FROM rw_apobase_rezept WHERE erezeptid = @ERezeptID AND NOT dipzn IN (2567024,6461110,9999175,9999005,9999057));
	
	-- PZN vom Vorgang
	SET @PznVorgang = (SELECT TOP 1 dipzn FROM rw_apobase_vorgaenge WHERE didate = @DatumVorgang AND iVgNr = @Vorgangsnummer AND dipzn = @PznERezept);
	
	-- Rezeptnummer vom Vorgang
	SET @RpNrNeu = (SELECT TOP 1 iRpNr FROM rw_apobase_vorgaenge WHERE didate = @DatumVorgang AND iVgNr = @Vorgangsnummer AND dipzn = @PznERezept);

	-- Nummer Vorgang
	Set @LfdVG = (SELECT TOP 1 diLfdNr FROM RW_APOBASE_Vorgaenge WHERE iVgNr = @Vorgangsnummer and didate = @DatumVorgang and diPzn = @PznERezept);


--******************************************************************************************Variable Tabellen************************************************************************************************************************************************************************************------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Laufende Nummer vom E-Rezept------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @ERezeptLFD TABLE (dilfdnr int);

		INSERT INTO @ERezeptLFD (dilfdnr) 
			SELECT diLfdNr FROM rw_apobase_rezept WHERE ERezeptID = @ERezeptID;

	
--Laufende Nummer vom neuen Vorgang------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @VgLfdNr TABLE (dilfdnr int);

		INSERT INTO @VgLfdNr (dilfdnr) 
			SELECT diLfdNr FROM rw_apobase_vorgaenge 
			WHERE didate = @DatumVorgang 
				AND iVgNr = @Vorgangsnummer 
				AND irpnr = @RpNrNeu;


--Laufende Nummer vom neuen Rezept--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @RezeptLfdNeu TABLE (dilfdnr int);
	
		INSERT INTO @RezeptLfdNeu (dilfdnr) 
			SELECT diLfdNr FROM rw_apobase_rezept 
				WHERE didate = @DatumVorgang 
				AND iRpNr = @RpNrNeu 
				AND (diPzn = @PznERezept OR dipzn IN (2567024,6461110,9999175,9999005,9999057))


--******************************************************************************************Fehlermeldungen************************************************************************************************************************************************************************************************************************************************----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Schon zugewiesen----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------			
		IF (@DatumErezept = @DatumVorgang) AND (@RpNrERezept = @RpNrNeu)
			BEGIN
				print 'Ist schon zugewiesen!';
				Rollback;
				Return;
			END

--Diesselbe PZN----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF (@PznERezept != @PznVorgang) OR (@PznVorgang IS NULL)
			BEGIN
				ROLLBACK;
				PRINT 'Es wurde nicht dasselbe Medikament gefunden!';
				RETURN;
			END
			
--Existieren Vorgangszeilen----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
		SELECT @ROWCOUNT = COUNT(*) FROM @VgLfdNr;
		IF (@ROWCOUNT = 0)
			BEGIN
				ROLLBACK;
				Print 'Es wurde kein Vorgang gefunden!';
				RETURN;
			END

--******************************************************************************************Änderungen************************************************************************************************************************************************************************************----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Gleiches Datum----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF (@DatumVorgang = @DatumErezept)
		BEGIN
		   UPDATE RW_APOBASE_Vorgaenge SET irpnr = @RpNrERezept WHERE dilfdnr in (Select diLfdNr from @VgLfdNr);
		   DELETE FROM rw_apobase_rezept WHERE didate = @DatumVorgang AND iRpNr = @RpNrNeu AND dipzn = @PznERezept;
			PRINT 'Gleiches Datum';
			
			-- Charge eintragen
			IF (@Charge = '0000') or (@Charge = '0') or (@Charge = NULL) or (@Charge is NULL)
				BEGIN
					-- Keine Charge eintragen
					PRINT 'Kein Chargenparameter!';
				END
			ELSE 
				BEGIN
					DELETE FROM RW_MODUL_SEC_VORGANG_SECURPHARM WHERE SecurpharmID = @ERezeptID;
					DELETE FROM RW_MODUL_SEC_Securpharm WHERE SecurPharmID = @ERezeptID;
					
					insert into RW_MODUL_SEC_VORGANG_SECURPHARM (diLfdNr, SecurpharmID, iVgNr, diPzn, diDate)
					values (@LfdVG, @ERezeptID, @Vorgangsnummer ,@PznERezept, @DatumVorgang)

					insert into RW_MODUL_SEC_Securpharm (SecurPharmID, Charge, SN, Verfall)
					values (@ERezeptID, @Charge, 'Manuell', 99998877)
				END
			
			Delete from RW_EREZEPT_Abrechnung where ERezept = @ERezeptID; 
			Update rw_apobase_rezept set cKontrollStatus = 0, cFehlerTyp = 0 where ERezept = @ERezeptID;

			-- ERezept, Vorgang und Rezept vom Vorgang ausgeben um die Änderungen zu sehen
			SELECT ERezeptID,* FROM RW_APOBASE_Rezept WHERE ERezeptID = @ERezeptID;
			SELECT * FROM RW_APOBASE_Vorgaenge WHERE iVgNr = @Vorgangsnummer AND diDate = @DatumVorgang;
			SELECT ERezeptID,ERezeptSecret,Markt,* FROM RW_APOBASE_Rezept WHERE dilfdnr in (select dilfdnr from @RezeptLfdNeu);
			SELECT * FROM RW_MODUL_SEC_Securpharm WHERE SecurPharmID = @ERezeptID;
				
			RETURN;
		END

--Ungleiches Datum--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF (@DatumVorgang != @DatumErezept)
		BEGIN 
		
	--Rezeptnummer 0 Abbruch------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			IF (@RpNrNeu = 0)
			BEGIN
				PRINT 'Rezeptnummer 0 auf Vorgang nicht zugelassen!';
				ROLLBACK;
				RETURN;
			END
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
			
			UPDATE R 
			SET R.Markt = E.Markt, R.ERezeptID = E.ERezeptID,R.ImportFAM = E.ImportFAM,R.ERezeptSecret = E.ERezeptSecret,
				R.PreisguenstigesFAM = E.PreisguenstigesFAM,R.Rabattvertragerfuellung = E.Rabattvertragerfuellung
			FROM RW_APOBASE_Rezept R
			INNER JOIN @RezeptLfdNeu L ON R.diLfdNr = L.dilfdnr
			INNER JOIN RW_APOBASE_Rezept E ON R.dipzn = E.dipzn
				WHERE E.ERezeptID = @ERezeptID;

			DELETE FROM RW_APOBASE_Rezept WHERE diLfdNr IN (SELECT diLfdNr FROM @ERezeptLFD);
			PRINT 'Ungleiches Datum';

			-- Charge eintragen
			IF (@Charge = '0000') or (@Charge = '0') or (@Charge = NULL) or (@Charge is NULL)
				BEGIN
					-- Keine Charge eintragen
					PRINT 'Kein Chargenparameter!';
				END
			ELSE 
				BEGIN
					DELETE FROM RW_MODUL_SEC_VORGANG_SECURPHARM WHERE SecurpharmID = @ERezeptID;
					DELETE FROM RW_MODUL_SEC_Securpharm WHERE SecurPharmID = @ERezeptID;
				
					insert into RW_MODUL_SEC_VORGANG_SECURPHARM (diLfdNr, SecurpharmID, iVgNr, diPzn, diDate)
					values (@LfdVG, @ERezeptID, @Vorgangsnummer ,@PznERezept, @DatumVorgang)

					insert into RW_MODUL_SEC_Securpharm (SecurPharmID, Charge, SN, Verfall)
					values (@ERezeptID, @Charge, 'Manuell', 99998877)
				END
			
			Delete from RW_EREZEPT_Abrechnung where ERezept = @ERezeptID; 
			Update rw_apobase_rezept set cKontrollStatus = 0, cFehlerTyp = 0 where ERezept = @ERezeptID;
			
			-- ERezept, Vorgang und Rezept vom Vorgang ausgeben um die Änderungen zu sehen
			SELECT ERezeptID,* FROM RW_APOBASE_Rezept WHERE ERezeptID = @ERezeptID;
			SELECT * FROM RW_APOBASE_Vorgaenge WHERE iVgNr = @Vorgangsnummer AND diDate = @DatumVorgang;
			SELECT ERezeptID,ERezeptSecret,Markt,* FROM RW_APOBASE_Rezept WHERE dilfdnr in (select dilfdnr from @RezeptLfdNeu);
			SELECT * FROM RW_MODUL_SEC_Securpharm WHERE SecurPharmID = @ERezeptID;
			
			RETURN;
		END
--Procedure end--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	END
	