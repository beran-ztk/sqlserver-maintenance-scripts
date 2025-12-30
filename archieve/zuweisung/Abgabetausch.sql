	USE APOBASE;
	GO

	SET ANSI_NULLS ON
	GO

	SET QUOTED_IDENTIFIER ON
	GO

	IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Abgabetausch')
	DROP PROCEDURE Abgabetausch
	GO

	CREATE PROCEDURE [dbo].[Abgabetausch] (@ERezeptID NVARCHAR(30), @Vorgangsnummer INT, @DatumVorgang INT, @Charge NVARCHAR(30))

	AS 
	BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRANSACTION;
	

--******************************************************************************************Variablen************************************************************************************************************************************************************************************-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @RpNrNeu INT,@RpLfdNeu INT, @ROWCOUNT INT, @PznVorgang INT, @RpNrERezept INT, @DatumErezept INT, @LfdVG INT;

	-- Datum vom ERezept
	SET @DatumErezept = (SELECT TOP 1 didate FROM rw_apobase_rezept WHERE ERezeptID = @ERezeptID);
	
	-- Datum anpassen
	IF (@DatumVorgang = 0000) BEGIN SET @DatumVorgang = @DatumErezept;END
		
	-- Rezeptnummer vom ERezept
	SET @RpNrERezept = (SELECT TOP 1 irpnr FROM rw_apobase_rezept WHERE erezeptid = @ERezeptID AND NOT dipzn IN (2567024,6461110,9999175,9999005,9999057));
	
	-- PZN vom Vorgang
	SET @PznVorgang = (SELECT TOP 1 dipzn FROM rw_apobase_vorgaenge WHERE didate = @DatumVorgang AND iVgNr = @Vorgangsnummer AND not diPzn in (9999175, 9999005, 9999057, 2567024, 6461110, 2567001, 2567018) );
	
	-- Rezeptnummer vom Vorgang
	SET @RpNrNeu = (SELECT TOP 1 iRpNr FROM rw_apobase_vorgaenge WHERE didate = @DatumVorgang AND iVgNr = @Vorgangsnummer);

	-- Nummer Vorgang
	Set @LfdVG = (SELECT TOP 1 diLfdNr FROM RW_APOBASE_Vorgaenge WHERE iVgNr = @Vorgangsnummer and didate = @DatumVorgang);


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
				AND iRpNr = @RpNrNeu;


--******************************************************************************************Fehlermeldungen************************************************************************************************************************************************************************************************************************************************----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Schon zugewiesen----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------			
		IF (@DatumErezept = @DatumVorgang) AND (@RpNrERezept = @RpNrNeu)
			BEGIN
				print 'Ist schon zugewiesen!';
				Rollback;
				Return;
			END

--Rezeptnummer 0 Abbruch------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF (@RpNrNeu = 0)
			BEGIN
				PRINT 'Rezeptnummer 0 auf Vorgang nicht zugelassen!';
				ROLLBACK;
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

--E-Rezept-Daten----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	

	Declare @Edata table (Eid nvarchar(25), Esec nvarchar(max), m int, r int, p int, i int)

	insert into @Edata (Eid, Esec, m, r, p , i) select top 1 ERezeptID, ERezeptSecret, Markt, Rabattvertragerfuellung, PreisguenstigesFAM, ImportFAM from RW_APOBASE_Rezept where ERezeptID = @ERezeptID;

--******************************************************************************************Änderungen************************************************************************************************************************************************************************************----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Execute----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		BEGIN 
			UPDATE r
			SET ERezeptID = e.Eid, ERezeptSecret = e.Esec ,r.Markt = e.m, r.Rabattvertragerfuellung = e.r, r.PreisguenstigesFAM = e.p, r.ImportFAM = e.i, r.cKontrollStatus = 0, r.cFehlerTyp = 0
			FROM RW_APOBASE_Rezept r, @Edata e
			where r.diLfdNr in (Select diLfdNr from @RezeptLfdNeu);

			DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID = @ERezeptID;
			DELETE RW_APOBASE_Rezept WHERE diLfdNr IN (SELECT diLfdNr FROM @ERezeptLFD);

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
					values (@LfdVG, @ERezeptID, @Vorgangsnummer ,@PznVorgang, @DatumVorgang)

					insert into RW_MODUL_SEC_Securpharm (SecurPharmID, Charge, SN, Verfall)
					values (@ERezeptID, @Charge, 'Manuell', 99998877)
				END
		
			-- ERezept, Vorgang und Rezept vom Vorgang ausgeben um die Änderungen zu sehen
			SELECT ERezeptID,* FROM RW_APOBASE_Rezept WHERE ERezeptID = @ERezeptID;
			SELECT * FROM RW_APOBASE_Vorgaenge WHERE iVgNr = @Vorgangsnummer AND diDate = @DatumVorgang;
			SELECT ERezeptID,ERezeptSecret,Markt,* FROM RW_APOBASE_Rezept WHERE dilfdnr in (select dilfdnr from @RezeptLfdNeu);
			SELECT * FROM RW_MODUL_SEC_Securpharm WHERE SecurPharmID = @ERezeptID;
			
			RETURN;
		END

--Procedure end--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	END
	