USE [Apobase]
GO
/****** Object:  StoredProcedure [dbo].[sp_VerbundBearbeiteCacheHistorie]    Script Date: 11.07.2025 17:42:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_VerbundBearbeiteCacheHistorie]
AS
BEGIN	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	   
	--Transaktion starten
	Begin TRAN
	BEGIN
		SELECT * FROM RW_MODUL_VerbundCacheHistorie WITH (XLOCK)		--Cache-Tabelle lock	

		DECLARE @diLfdCache INT

		DECLARE Cache_Cursor CURSOR FOR							--Cursor erstellen zum Durchlaufen
			SELECT TOP 300 diLfdNr FROM RW_MODUL_VerbundCacheHistorie ORDER BY dtDatum

		OPEN Cache_Cursor 

		FETCH NEXT FROM Cache_Cursor INTO @diLfdCache

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--Prüfe in den beiden Remote-Apotheken, ob KdNr auch im Cache ist
			DECLARE @Ergebnis1 INT
			DECLARE @Ergebnis2 INT
			--EXEC @Ergebnis1 = dbo.sp_VerbundPruefeKonfliktHistorie @diLfdNr = @diLfdCache, @remotePartner = N'[192.168.114.101\SQLEXPRESS].Apobase', @remoteSP = N'dbo.FKT_TranslateHisNrToGruene'
			--EXEC @Ergebnis2 = dbo.sp_VerbundPruefeKonfliktHistorie @diLfdNr = @diLfdCache, @remotePartner = N'[SERV4591469\SQLEXPRESS]Apobase', @remoteSP = N'dbo.FKT_TranslateHisNrToKastell'
			
			SET @Ergebnis1 = 0
			SET @Ergebnis2 = 0
			--Falls nein in beiden Remotes -> Update
			IF (@Ergebnis1 = 0 AND @Ergebnis2 = 0)
			BEGIN
				--UPDATE
				PRINT @diLfdCache
							--UPDATE Partner Gruene
			
				INSERT INTO [192.168.114.101\SQLEXPRESS].[Apobase].dbo.RW_APOBASE_HistorieInsert
				(diLfdNr,
				[diDate]
           ,[diTime]
           ,[diInstanceNr]
           ,[diPzn]
           ,[diMic2]
           ,[strText]
           ,[diVk]
           ,[diZahlbetrag]
           ,[iAnteil]
           ,[diZuzahlung]
           ,[iAnzahl]
           ,[iMwSt]
           ,[diKdNr]
           ,[cRpStatus]
           ,[diKassGrId]
           ,[bEuro]
           ,[bStorno]
           ,[cZahlungsStatus]
           ,[diTaetigkeitId]
           ,[strErgebnis]
           ,[bMed]
           ,[iVgNr]
           ,[bEchterZahlbetrag]
           ,[strIndKey]
           ,[strChargennummer]
           ,[strRechnungsnummer]
           ,[dilfdRechnungsnummer]
           ,[diBGAPartner]
           ,[cRezeptpflicht]
           ,[diEk]
           ,[diErtrag]
           ,[cApopflicht]
           ,[diBonusWert]
           ,[diBonusPunkte]
           ,[cBonusTyp]
           ,[bBonusSchonGewaehrt]
           ,[strDarKurz]
           ,[strMng]
           ,[strMngEinh]
           ,[cErtragTyp]
           ,[cAnteileTyp]
           ,[cUmsatzTyp]
           ,[cZahlbetragTyp]
           ,[cAnzeigeTyp]
           ,[cWoherTyp]
           ,[cRabattTyp]
           ,[iRechStatus]
           ,[diRechDat]
           ,[diZahlDat]
           ,[cUserNr]
           ,[cInteraktionsTyp]
           ,[dfKey_FAM]
           ,[diLfdNrVorgang]
           ,[diLfdNrRezept]
           ,[diLfdNrBotendienst]
           ,[diLfdNrNachlieferung]
           ,[diLfdNrVorgriff]
           ,[strVerbund]
           ,[dtLzAustausch]
           ,[diLfdNrHistorieVerbund]
				)
				SELECT 
				dbo.sp_TranslateLfdNrToRemote(diLfdNr, strVerbund),
				[diDate]
           ,[diTime]
           ,[diInstanceNr]
           ,[diPzn]
           ,[diMic2]
           ,[strText]
           ,[diVk]
           ,[diZahlbetrag]
           ,[iAnteil]
           ,[diZuzahlung]
           ,[iAnzahl]
           ,[iMwSt]
           ,dbo.FKT_TranslateKdNrToGruene([diKdNr])
           ,[cRpStatus]
           ,[diKassGrId]
           ,[bEuro]
           ,[bStorno]
           ,[cZahlungsStatus]
           ,[diTaetigkeitId]
           ,[strErgebnis]
           ,[bMed]
           ,[iVgNr]
           ,[bEchterZahlbetrag]
           ,[strIndKey]
           ,[strChargennummer]
           ,[strRechnungsnummer]
           ,[dilfdRechnungsnummer]
           ,[diBGAPartner]
           ,[cRezeptpflicht]
           ,[diEk]
           ,[diErtrag]
           ,[cApopflicht]
           ,[diBonusWert]
           ,[diBonusPunkte]
           ,[cBonusTyp]
           ,[bBonusSchonGewaehrt]
           ,[strDarKurz]
           ,[strMng]
           ,[strMngEinh]
           ,[cErtragTyp]
           ,[cAnteileTyp]
           ,[cUmsatzTyp]
           ,[cZahlbetragTyp]
           ,[cAnzeigeTyp]
           ,[cWoherTyp]
           ,[cRabattTyp]
           ,[iRechStatus]
           ,[diRechDat]
           ,[diZahlDat]
           ,[cUserNr]
           ,[cInteraktionsTyp]
           ,[dfKey_FAM]
           ,[diLfdNrVorgang]
           ,[diLfdNrRezept]
           ,[diLfdNrBotendienst]
           ,[diLfdNrNachlieferung]
           ,[diLfdNrVorgriff]
           ,[dbo].[sp_TranslateVBKZToGruene]([strVerbund])
           ,[dtLzAustausch]
           ,[diLfdNrHistorieVerbund]
				FROM RW_APOBASE_Historie WHERE diLfdNr = @diLfdCache
			

						--UPDATE Partner Kastell
			
				INSERT INTO [SERV4591469\SQLEXPRESS].[Apobase].dbo.RW_APOBASE_HistorieInsert
				(diLfdNr,
				[diDate]
           ,[diTime]
           ,[diInstanceNr]
           ,[diPzn]
           ,[diMic2]
           ,[strText]
           ,[diVk]
           ,[diZahlbetrag]
           ,[iAnteil]
           ,[diZuzahlung]
           ,[iAnzahl]
           ,[iMwSt]
           ,[diKdNr]
           ,[cRpStatus]
           ,[diKassGrId]
           ,[bEuro]
           ,[bStorno]
           ,[cZahlungsStatus]
           ,[diTaetigkeitId]
           ,[strErgebnis]
           ,[bMed]
           ,[iVgNr]
           ,[bEchterZahlbetrag]
           ,[strIndKey]
           ,[strChargennummer]
           ,[strRechnungsnummer]
           ,[dilfdRechnungsnummer]
           ,[diBGAPartner]
           ,[cRezeptpflicht]
           ,[diEk]
           ,[diErtrag]
           ,[cApopflicht]
           ,[diBonusWert]
           ,[diBonusPunkte]
           ,[cBonusTyp]
           ,[bBonusSchonGewaehrt]
           ,[strDarKurz]
           ,[strMng]
           ,[strMngEinh]
           ,[cErtragTyp]
           ,[cAnteileTyp]
           ,[cUmsatzTyp]
           ,[cZahlbetragTyp]
           ,[cAnzeigeTyp]
           ,[cWoherTyp]
           ,[cRabattTyp]
           ,[iRechStatus]
           ,[diRechDat]
           ,[diZahlDat]
           ,[cUserNr]
           ,[cInteraktionsTyp]
           ,[dfKey_FAM]
           ,[diLfdNrVorgang]
           ,[diLfdNrRezept]
           ,[diLfdNrBotendienst]
           ,[diLfdNrNachlieferung]
           ,[diLfdNrVorgriff]
           ,[strVerbund]
           ,[dtLzAustausch]
           ,[diLfdNrHistorieVerbund]
				)
				SELECT 
				dbo.sp_TranslateLfdNrToRemote(diLfdNr, strVerbund),
				[diDate]
           ,[diTime]
           ,[diInstanceNr]
           ,[diPzn]
           ,[diMic2]
           ,[strText]
           ,[diVk]
           ,[diZahlbetrag]
           ,[iAnteil]
           ,[diZuzahlung]
           ,[iAnzahl]
           ,[iMwSt]
           ,dbo.FKT_TranslateKdNrToKastell([diKdNr])
           ,[cRpStatus]
           ,[diKassGrId]
           ,[bEuro]
           ,[bStorno]
           ,[cZahlungsStatus]
           ,[diTaetigkeitId]
           ,[strErgebnis]
           ,[bMed]
           ,[iVgNr]
           ,[bEchterZahlbetrag]
           ,[strIndKey]
           ,[strChargennummer]
           ,[strRechnungsnummer]
           ,[dilfdRechnungsnummer]
           ,[diBGAPartner]
           ,[cRezeptpflicht]
           ,[diEk]
           ,[diErtrag]
           ,[cApopflicht]
           ,[diBonusWert]
           ,[diBonusPunkte]
           ,[cBonusTyp]
           ,[bBonusSchonGewaehrt]
           ,[strDarKurz]
           ,[strMng]
           ,[strMngEinh]
           ,[cErtragTyp]
           ,[cAnteileTyp]
           ,[cUmsatzTyp]
           ,[cZahlbetragTyp]
           ,[cAnzeigeTyp]
           ,[cWoherTyp]
           ,[cRabattTyp]
           ,[iRechStatus]
           ,[diRechDat]
           ,[diZahlDat]
           ,[cUserNr]
           ,[cInteraktionsTyp]
           ,[dfKey_FAM]
           ,[diLfdNrVorgang]
           ,[diLfdNrRezept]
           ,[diLfdNrBotendienst]
           ,[diLfdNrNachlieferung]
           ,[diLfdNrVorgriff]
           ,[dbo].[sp_TranslateVBKZToKastell]([strVerbund])
           ,[dtLzAustausch]
           ,[diLfdNrHistorieVerbund]
				FROM RW_APOBASE_Historie WHERE diLfdNr = @diLfdCache

				DELETE FROM RW_MODUL_VerbundCacheHistorie WHERE diLfdNr = @diLfdCache

			END
			
			FETCH NEXT FROM Cache_Cursor INTO @diLfdCache
		END
		CLOSE Cache_Cursor
		DEALLOCATE Cache_Cursor

		PRINT 'RemoteUpdateGruene'
		EXEC [192.168.114.101\SQLEXPRESS].[Apobase].dbo.[sp_RemoteUpdateHistorie]
		PRINT 'RemoteUpdateKastell'
		EXEC [SERV4591469\SQLEXPRESS].[Apobase].dbo.[sp_RemoteUpdateHistorie]
	END
	COMMIT TRAN
	SET XACT_ABORT OFF
END



