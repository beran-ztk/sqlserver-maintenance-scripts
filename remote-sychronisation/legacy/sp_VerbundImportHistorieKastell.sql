USE [Apobase]
GO

/****** Object:  StoredProcedure [dbo].[sp_VerbundImportHistorieKastell]    Script Date: 11.07.2025 17:43:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Florian Horzella, david Dorst>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_VerbundImportHistorieKastell]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DBCC TRACEON(460, -1);
--- Kunde im Verbund Mergen ---

/*
Der kundenstamm remote muss in den Kundenstamm local übernommen werden. 
Dabei müssen verschwundene Datensätze gelöscht oder ausgeblendet werden (ausblenden: bspw. Will ich doch behalten, hat noch was offen...) 
Dabei müssen neue Datensätze eingefügt werden - diKdNrAuto wird diKdNr, strIdent erhält bspw. 'Apotheke1' (eine zuordnung) 
Dabei müssen vorhandene Datensätze aktualisiert werden - bspw. Name hat sich geändert, Anschrift, Rechnungskunde

Achtung: System funktioniert bei Kunde! 
diKdNrRechnung oder diKdNrHpt müssen MIT übersetzt werden (bei INSERT) - danach ist anfassen verboten auf die neue diKdNrAuto - Der fall ist in schritt 1 nicht zu beachten
ACHTUNG: Aus der Quelle dürfen nur datensätze mit diKdNr = 0 AND strIdent NOT LIKE 'ApothekeZiel' übernommen werden
*/
BEGIN TRY
SELECT * INTO #TempHistorie
FROM [SERV4591469\SQLEXPRESS].[Apobase].[dbo].RW_APOBASE_Historie 
AS RemoteHistorie
WHERE
RemoteHistorie.diLfdNrHistorieVerbund = 0 
AND RemoteHistorie.diKdNr NOT IN (13533,14378,15296,14882,12177,13156,15718,29724,13866,13537,21698,12335,13995,12747,16105,19148,12630,17462,20725,16294,30804,12631,17283,25152,27582,15274,25825,13353,14753,13147)
AND RemoteHistorie.diDate > 20240400
AND RemoteHistorie.bStorno = 0

SELECT * INTO TempKundeHistorieAbgleich
FROM [SERV4591469\SQLEXPRESS].[Apobase].[dbo].RW_APOBASE_Kunde

INSERT INTO RW_APOBASE_Historie
      ([diDate]
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
           ,[diLfdNrHistorieVerbund])
	 SELECT 
	  RemoteHistorie.[diDate]
           ,RemoteHistorie.[diTime]
           ,RemoteHistorie.[diInstanceNr]
           ,RemoteHistorie.[diPzn]
           ,RemoteHistorie.[diMic2]
           ,RemoteHistorie.[strText]
           ,RemoteHistorie.[diVk]
           ,RemoteHistorie.[diZahlbetrag]
           ,RemoteHistorie.[iAnteil]
           ,RemoteHistorie.[diZuzahlung]
           ,RemoteHistorie.[iAnzahl]
           ,RemoteHistorie.[iMwSt]
           ,dbo.FKT_TranslateKdNrFromKastell(RemoteHistorie.[diKdNr])
           ,RemoteHistorie.[cRpStatus]
           ,RemoteHistorie.[diKassGrId]
           ,1
           ,RemoteHistorie.[bStorno]
           ,RemoteHistorie.[cZahlungsStatus]
           ,RemoteHistorie.[diTaetigkeitId]
           ,RemoteHistorie.[strErgebnis]
           ,RemoteHistorie.[bMed]
           ,RemoteHistorie.[iVgNr]
           ,RemoteHistorie.[bEchterZahlbetrag]
           ,RemoteHistorie.[strIndKey]
           ,RemoteHistorie.[strChargennummer]
           ,RemoteHistorie.[strRechnungsnummer]
           ,RemoteHistorie.[dilfdRechnungsnummer]
           ,RemoteHistorie.[diBGAPartner]
           ,RemoteHistorie.[cRezeptpflicht]
           ,RemoteHistorie.[diEk]
           ,RemoteHistorie.[diErtrag]
           ,RemoteHistorie.[cApopflicht]
           ,RemoteHistorie.[diBonusWert]
           ,RemoteHistorie.[diBonusPunkte]
           ,RemoteHistorie.[cBonusTyp]
           ,RemoteHistorie.[bBonusSchonGewaehrt]
           ,RemoteHistorie.[strDarKurz]
           ,RemoteHistorie.[strMng]
           ,RemoteHistorie.[strMngEinh]
           ,RemoteHistorie.[cErtragTyp]
           ,RemoteHistorie.[cAnteileTyp]
           ,RemoteHistorie.[cUmsatzTyp]
           ,RemoteHistorie.[cZahlbetragTyp]
           ,RemoteHistorie.[cAnzeigeTyp]
           ,RemoteHistorie.[cWoherTyp]
           ,RemoteHistorie.[cRabattTyp]
           ,RemoteHistorie.[iRechStatus]
           ,RemoteHistorie.[diRechDat]
           ,RemoteHistorie.[diZahlDat]
           ,RemoteHistorie.[cUserNr]
           ,RemoteHistorie.[cInteraktionsTyp]
           ,RemoteHistorie.[dfKey_FAM]
           ,0
           ,0
           ,0
           ,0
           ,0
             ,'Verbund_Kastell'
           ,CURRENT_TIMESTAMP
           ,RemoteHistorie.diLfdNr FROM 
RW_APOBASE_Historie AS LH 
RIGHT JOIN #TempHistorie
AS RemoteHistorie
ON LH.diLfdNrHistorieVerbund = RemoteHistorie.diLfdNr 
AND LH.strVerbund IN ('Verbund_Kastell') 
WHERE LH.diLfdNr  IS NULL


DROP TABLE TempKundeHistorieAbgleich

END TRY

BEGIN CATCH
    -- Fehlerbehandlung
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    PRINT 'Fehler: ' + @ErrorMessage;
END CATCH

END






GO


