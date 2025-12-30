USE [Apobase]
GO

/****** Object:  StoredProcedure [dbo].[sp_VerbundBearbeiteCacheKunde]    Script Date: 11.07.2025 17:43:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_VerbundBearbeiteCacheKunde]
AS
BEGIN	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	--Transaktion starten
	Begin DISTRIBUTED TRANSACTION
	BEGIN
		SELECT * FROM RW_MODUL_VerbundCacheKunde WITH (XLOCK)		--Cache-Tabelle lock	

		DECLARE @diKdCache INT

		DECLARE Cache_Cursor CURSOR FOR							--Cursor erstellen zum Durchlaufen
			SELECT diKdNr FROM RW_MODUL_VerbundCacheKunde

		OPEN Cache_Cursor 

		FETCH NEXT FROM Cache_Cursor INTO @diKdCache

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--Prüfe in den beiden Remote-Apotheken, ob KdNr auch im Cache ist
			PRINT @diKdCache
			DECLARE @Ergebnis1 INT
			DECLARE @Ergebnis2 INT
			EXEC @Ergebnis1 = [sp_VerbundPruefeKonfliktKundeKastell] @diKdNr = @diKdCache
			EXEC @Ergebnis2 = [sp_VerbundPruefeKonfliktKundeGruene] @diKdNr = @diKdCache
			
			--Falls nein in beiden Remotes -> Update
			IF (@Ergebnis1 = 0 AND @Ergebnis2 = 0)
			BEGIN
				--UPDATE
				PRINT @diKdCache
				--- Kastell TempTable 
				DECLARE @Trans int
				SET @Trans = dbo.FKT_TranslateKdNrToKastell(@diKdCache)
				IF @Trans = 0
				BEGIN 
					FETCH NEXT FROM Cache_Cursor INTO @diKdCache
					CONTINUE
				END

				INSERT INTO [SERV4591469\SQLEXPRESS].Apobase.dbo.RW_APOBASE_KundeInsert SELECT [strVorname],
					[strZwVorname],
					[strName],
					[strTitel],
					[strAnrede],
					[strStrasse],
					[diPlz],
					[strOrt],
					[strPlz],
					[strTelNrP],
					[strTelNrB],
					[strTelNrM],
					[strFaxNr],
					[strEmail],
					[diGebDat],
					[strNotPers],
					[strNotTelNr],
					[bRabattEk],
					[iRabatt],
					[iRabatt2],
					[iRabatt3],
					[iRabatt4], 
					[strVersNr],
					[diKKNr],
					[diBefrBisDat],
					[diGltBisDat], 
					[cStatus],
					[iKuKaNr],
					[cKuKaStat],
					[bMonatsAbr],
					[bQuartAbr],
					[bJahresAbr],
					[bNichtSammel],
					[bNichtEinzel],
					[bAbbuchung],
					[bAllergiker],
					@Trans,
					[bKonto],
					[bMed],
					[bNotiz],
					[strHausarzt],
					[strNotiz],
					[bSchnellerfassung],
					[bytGeschlecht],
					[strInternet],
					[strKKNummer],
					[dbo].[FKT_TranslateKdNrToKastell]([diKdNrHpt]),
					[bMedNurAkt],
					[bRabInVg],
					[bNoInteraktionsCheck],
					[bHausapotheke],
					[cStdRpStatusInVg],
					[bBefreiungGueltig],
					[dbo].[FKT_TranslateKdNrToKastell]([diKdNrRechnung]),
					[strZahlungsziel],
					[strBank],
					[strBlz],
					[strKtNr],
					[bFragen1],
					[bFragen2],
					[bFragen3],
					[bFragen4],
					[bJahresrabatt],
					[diErtragVJ],
					[bChargenabfrage],
					[bBonusmodell],
					[bBlister],
					[strPaybackKdNr],
					[bKKNrIsPayback],
					[diAnzeigeGruppe],
					[bGeloescht],
					[bNoHistorie],
					[byDSE],
					[strBIC],
					[strIBAN],
					[strMandatsRefNr],
					[cAbbuchungsermaechtigung],
					[cEinverstaendniserklaerung],
					[dwEinverstaendniserklaerung],
					[dwAbbuchungsermaechtigung],
					[strVerwendungszweck1],
					[strVerwendungszweck2],
					[strVerwendungszweck3],
					[bOhneVerkaufStatistik],
					[strAdresszusatz] 
					FROM RW_APOBASE_Kunde AS K
					WHERE K.diKdNrAuto = @diKdCache
				--- ENDE KastellTemp
				--- G Update 
				SET @Trans = dbo.FKT_TranslateKdNrToGruene(@diKdCache)
				IF @Trans = 0
				BEGIN 
					FETCH NEXT FROM Cache_Cursor INTO @diKdCache
					CONTINUE
				END
				INSERT INTO [192.168.114.101\SQLEXPRESS].Apobase.dbo.RW_APOBASE_KundeInsert
					SELECT [strVorname],
					[strZwVorname],
					[strName],
					[strTitel],
					[strAnrede],
					[strStrasse],
					[diPlz],
					[strOrt],
					[strPlz],
					[strTelNrP],
					[strTelNrB],
					[strTelNrM],
					[strFaxNr],
					[strEmail],
					[diGebDat],
					[strNotPers],
					[strNotTelNr],
					[bRabattEk],
					[iRabatt],
					[iRabatt2],
					[iRabatt3],
					[iRabatt4], 
					[strVersNr],
					[diKKNr],
					[diBefrBisDat],
					[diGltBisDat], 
					[cStatus],
					[iKuKaNr],
					[cKuKaStat],
					[bMonatsAbr],
					[bQuartAbr],
					[bJahresAbr],
					[bNichtSammel],
					[bNichtEinzel],
					[bAbbuchung],
					[bAllergiker],
					@Trans,
					[bKonto],
					[bMed],
					[bNotiz],
					[strHausarzt],
					[strNotiz],
					[bSchnellerfassung],
					[bytGeschlecht],
					[strInternet],
					[strKKNummer],
					[dbo].[FKT_TranslateKdNrToGruene]([diKdNrHpt]),
					[bMedNurAkt],
					[bRabInVg],
					[bNoInteraktionsCheck],
					[bHausapotheke],
					[cStdRpStatusInVg],
					[bBefreiungGueltig],
					[dbo].[FKT_TranslateKdNrToGruene]([diKdNrRechnung]),
					[strZahlungsziel],
					[strBank],
					[strBlz],
					[strKtNr],
					[bFragen1],
					[bFragen2],
					[bFragen3],
					[bFragen4],
					[bJahresrabatt],
					[diErtragVJ],
					[bChargenabfrage],
					[bBonusmodell],
					[bBlister],
					[strPaybackKdNr],
					[bKKNrIsPayback],
					[diAnzeigeGruppe],
					[bGeloescht],
					[bNoHistorie],
					[byDSE],
					[strBIC],
					[strIBAN],
					[strMandatsRefNr],
					[cAbbuchungsermaechtigung],
					[cEinverstaendniserklaerung],
					[dwEinverstaendniserklaerung],
					[dwAbbuchungsermaechtigung],
					[strVerwendungszweck1],
					[strVerwendungszweck2],
					[strVerwendungszweck3],
					[bOhneVerkaufStatistik],
					[strAdresszusatz] 
					FROM RW_APOBASE_Kunde AS K
					WHERE K.diKdNrAuto = @diKdCache
				--- ENDE G

				DELETE FROM RW_MODUL_VerbundCacheKunde WHERE diKdNr = @diKdCache

			END
			
			FETCH NEXT FROM Cache_Cursor INTO @diKdCache
		END
		CLOSE Cache_Cursor
		DEALLOCATE Cache_Cursor

		EXEC [SERV4591469\SQLEXPRESS].Apobase.dbo.sp_RemoteUpdateKunde
		EXEC [192.168.114.101\SQLEXPRESS].Apobase.dbo.sp_RemoteUpdateKunde

	END
	COMMIT TRAN
	SET XACT_ABORT OFF
END


GO


