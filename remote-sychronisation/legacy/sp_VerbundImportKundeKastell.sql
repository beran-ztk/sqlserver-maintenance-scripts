USE [Apobase]
GO

/****** Object:  StoredProcedure [dbo].[sp_VerbundImportKundeKastell]    Script Date: 11.07.2025 17:43:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_VerbundImportKundeKastell]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
MERGE RW_APOBASE_Kunde AS LOCALKUNDE
USING (SELECT * FROM [SERV4591469\SQLEXPRESS].[Apobase].[dbo].[RW_APOBASE_Kunde]) AS REMOTEKUNDE
ON (LOCALKUNDE.diKdNr = REMOTEKUNDE.diKdNrAuto AND LOCALKUNDE.strIdent IN ('Verbund_Kastell'))
WHEN NOT MATCHED AND REMOTEKUNDE.diKdNr = 0--REMOTEKUNDE.strIdent NOT LIKE 'Verbund_Roemer'  -- AND
THEN INSERT -- Alles was vom Fremddatensatz eingefügt werden soll
      (diKdNr
      ,strVorname
      ,strZwVorname
      ,strName
      ,strTitel
      ,strAnrede
      ,strStrasse
      ,diPlz
      ,strOrt
      ,strPlz
      ,strTelNrP
      ,strTelNrB
      ,strTelNrM
      ,strFaxNr
      ,strEmail
      ,diGebDat
      ,strNotPers
      ,strNotTelNr
      ,bRabattEk
      ,iRabatt
      ,iRabatt2
      ,iRabatt3
      ,iRabatt4
      ,strVersNr
      ,diKKNr
      ,diBefrBisDat
      ,diGltBisDat
      ,diKontakteLJ
      ,diKontakteVJ
      ,cStatus
      ,strIdent
      ,iKuKaNr
      ,cKuKaStat
      ,bMonatsAbr
      ,bQuartAbr
      ,bJahresAbr
      ,bNichtSammel
      ,bNichtEinzel
      ,bAbbuchung
      ,bAllergiker
      ,bKonto
      ,bMed
      ,bNotiz
      ,strHausarzt
      ,strNotiz
      ,strSuchName
      ,bSchnellerfassung
      ,bytGeschlecht
      ,strInternet
      ,strKKNummer
      ,cOffeneBestellungen
      ,cPostenNachlieferung
      ,cPostenVorgriff
	  ,diKdNrHpt
      --,diAnzahlSub
      ,bMedNurAkt
      ,bRabInVg
      ,bNoInteraktionsCheck
      ,bHausapotheke
      ,cStdRpStatusInVg
      ,bBefreiungGueltig
      ,diZZLJ
      ,diKdNrRechnung
      ,strZahlungsziel
      ,strBank
      ,strBlz
      ,strKtNr
      ,bFragen1
      ,bFragen2
      ,bFragen3
      ,bFragen4
      ,bJahresrabatt
      ,diBGAPartner
      ,bChargenabfrage
      ,bBonusmodell
      ,bBlister
      ,strPaybackKdNr
      ,bKKNrIsPayback
      ,diAnzeigeGruppe
      ,bGeloescht
      ,bNoHistorie
      ,byDSE
      ,strBIC
      ,strIBAN
      ,strMandatsRefNr
      ,cAbbuchungsermaechtigung
      ,cEinverstaendniserklaerung
      ,dwEinverstaendniserklaerung
      ,dwAbbuchungsermaechtigung
      ,strVerwendungszweck1
      ,strVerwendungszweck2
      ,strVerwendungszweck3)
	  VALUES
	  (REMOTEKUNDE.diKdNrAuto
      ,REMOTEKUNDE.strVorname
      ,REMOTEKUNDE.strZwVorname
      ,REMOTEKUNDE.strName
      ,REMOTEKUNDE.strTitel
      ,REMOTEKUNDE.strAnrede
      ,REMOTEKUNDE.strStrasse
      ,REMOTEKUNDE.diPlz
      ,REMOTEKUNDE.strOrt
      ,REMOTEKUNDE.strPlz
      ,REMOTEKUNDE.strTelNrP
      ,REMOTEKUNDE.strTelNrB
      ,REMOTEKUNDE.strTelNrM
      ,REMOTEKUNDE.strFaxNr
      ,REMOTEKUNDE.strEmail
      ,REMOTEKUNDE.diGebDat
      ,REMOTEKUNDE.strNotPers
      ,REMOTEKUNDE.strNotTelNr
      ,REMOTEKUNDE.bRabattEk
      ,REMOTEKUNDE.iRabatt
      ,REMOTEKUNDE.iRabatt2
      ,REMOTEKUNDE.iRabatt3
      ,REMOTEKUNDE.iRabatt4
      ,REMOTEKUNDE.strVersNr
      ,REMOTEKUNDE.diKKNr
      ,REMOTEKUNDE.diBefrBisDat
      ,REMOTEKUNDE.diGltBisDat
      ,REMOTEKUNDE.diKontakteLJ
      ,REMOTEKUNDE.diKontakteVJ
      ,REMOTEKUNDE.cStatus
      ,'Verbund_Kastell'
      ,REMOTEKUNDE.iKuKaNr
      ,REMOTEKUNDE.cKuKaStat
      ,REMOTEKUNDE.bMonatsAbr
      ,REMOTEKUNDE.bQuartAbr
      ,REMOTEKUNDE.bJahresAbr
      ,REMOTEKUNDE.bNichtSammel
      ,REMOTEKUNDE.bNichtEinzel
      ,REMOTEKUNDE.bAbbuchung
      ,REMOTEKUNDE.bAllergiker
      ,REMOTEKUNDE.bKonto
      ,REMOTEKUNDE.bMed
      ,REMOTEKUNDE.bNotiz
      ,REMOTEKUNDE.strHausarzt
      ,REMOTEKUNDE.strNotiz
      ,REMOTEKUNDE.strSuchName
      ,REMOTEKUNDE.bSchnellerfassung
      ,REMOTEKUNDE.bytGeschlecht
      ,REMOTEKUNDE.strInternet
      ,REMOTEKUNDE.strKKNummer
      ,REMOTEKUNDE.cOffeneBestellungen
      ,REMOTEKUNDE.cPostenNachlieferung
      ,REMOTEKUNDE.cPostenVorgriff
	  ,REMOTEKUNDE.diKdNrHpt
      --,REMOTEKUNDE.diAnzahlSub
      ,REMOTEKUNDE.bMedNurAkt
      ,REMOTEKUNDE.bRabInVg
      ,REMOTEKUNDE.bNoInteraktionsCheck
      ,REMOTEKUNDE.bHausapotheke
      ,REMOTEKUNDE.cStdRpStatusInVg
      ,REMOTEKUNDE.bBefreiungGueltig
      ,REMOTEKUNDE.diZZLJ
      ,REMOTEKUNDE.diKdNrRechnung
      ,REMOTEKUNDE.strZahlungsziel
      ,REMOTEKUNDE.strBank
      ,REMOTEKUNDE.strBlz
      ,REMOTEKUNDE.strKtNr
      ,REMOTEKUNDE.bFragen1
      ,REMOTEKUNDE.bFragen2
      ,REMOTEKUNDE.bFragen3
      ,REMOTEKUNDE.bFragen4
      ,REMOTEKUNDE.bJahresrabatt
      ,REMOTEKUNDE.diBGAPartner
      ,REMOTEKUNDE.bChargenabfrage
      ,REMOTEKUNDE.bBonusmodell
      ,REMOTEKUNDE.bBlister
      ,REMOTEKUNDE.strPaybackKdNr
      ,REMOTEKUNDE.bKKNrIsPayback
      ,REMOTEKUNDE.diAnzeigeGruppe
      ,REMOTEKUNDE.bGeloescht
      ,REMOTEKUNDE.bNoHistorie
      ,REMOTEKUNDE.byDSE
      ,REMOTEKUNDE.strBIC
      ,REMOTEKUNDE.strIBAN
      ,REMOTEKUNDE.strMandatsRefNr
      ,REMOTEKUNDE.cAbbuchungsermaechtigung
      ,REMOTEKUNDE.cEinverstaendniserklaerung
      ,REMOTEKUNDE.dwEinverstaendniserklaerung
      ,REMOTEKUNDE.dwAbbuchungsermaechtigung
      ,REMOTEKUNDE.strVerwendungszweck1
      ,REMOTEKUNDE.strVerwendungszweck2
      ,REMOTEKUNDE.strVerwendungszweck3);

--WHEN NOT MATCHED BY target
--THEN UPDATE SET bGeloescht = 1 -- Eine mögliche Option wie mit einer Fremdlöschung umzugehen ist.

--Jede Transaktion wird in RW_APOBASE_KundeVerbundLog geschrieben.
/*
OUTPUT
       inserted.diKdNr
      ,inserted.strVorname
      ,inserted.strZwVorname
      ,inserted.strName
      ,inserted.strTitel
      ,inserted.strAnrede
      ,inserted.strStrasse
      ,inserted.diPlz
      ,inserted.strOrt
      ,inserted.strPlz
      ,inserted.strTelNrP
      ,inserted.strTelNrB
      ,inserted.strTelNrM
      ,inserted.strFaxNr
      ,inserted.strEmail
      ,inserted.diGebDat
      ,inserted.strNotPers
      ,inserted.strNotTelNr
      ,inserted.bRabattEk
      ,inserted.iRabatt
      ,inserted.iRabatt2
      ,inserted.iRabatt3
      ,inserted.iRabatt4
      ,inserted.strVersNr
      ,inserted.diKKNr
      ,inserted.diBefrBisDat
      ,inserted.diGltBisDat
      ,inserted.diKontakteLJ
      ,inserted.diKontakteVJ
      ,inserted.cStatus
      ,inserted.strIdent
      ,inserted.iAnzSubKdn
      ,inserted.diInfo
      ,inserted.iKuKaNr
      ,inserted.cKuKaStat
      ,inserted.diKoppelNr
      ,inserted.diRefJahr
      ,inserted.bMonatsAbr
      ,inserted.bQuartAbr
      ,inserted.bJahresAbr
      ,inserted.bNichtSammel
      ,inserted.bNichtEinzel
      ,inserted.bAbbuchung
      ,inserted.bAllergiker
      ,inserted.bKonto
      ,inserted.bMed
      ,inserted.bNotiz
      ,inserted.strHausarzt
      ,inserted.strNotiz
      ,inserted.strPhonemName
      ,inserted.strSuchName
      ,inserted.strExtPhonemName
      ,inserted.bSchnellerfassung
      ,inserted.bytGeschlecht
      ,inserted.strInternet
      ,inserted.strKKNummer
      ,inserted.cOffeneBestellungen
      ,inserted.cPostenBotendienst
      ,inserted.cPostenNachlieferung
      ,inserted.cPostenVorgriff
	  ,inserted.diKdNrHpt
     -- ,inserted.diAnzahlSub
      ,inserted.bMedNurAkt
      ,inserted.bRabInVg
      ,inserted.bNoInteraktionsCheck
      ,inserted.bHausapotheke
      ,inserted.cStdRpStatusInVg
      ,inserted.bBefreiungGueltig
      ,inserted.diZZLJ
      ,inserted.diKdNrRechnung
      ,inserted.strZahlungsziel
      ,inserted.strBank
      ,inserted.strBlz
      ,inserted.strKtNr
      ,inserted.bFragen1
      ,inserted.bFragen2
      ,inserted.bFragen3
      ,inserted.bFragen4
      ,inserted.bJahresrabatt
      ,inserted.diBGAPartner
      ,inserted.bChargenabfrage
      ,inserted.bBonusmodell
      ,inserted.bBlister
      ,inserted.strPaybackKdNr
      ,inserted.bKKNrIsPayback
      ,inserted.diAnzeigeGruppe
      ,inserted.bGeloescht
      ,inserted.bNoHistorie
      ,inserted.byDSE
      ,inserted.strBIC
      ,inserted.strIBAN
      ,inserted.strMandatsRefNr
      ,inserted.cAbbuchungsermaechtigung
      ,inserted.cEinverstaendniserklaerung
      ,inserted.dwEinverstaendniserklaerung
      ,inserted.dwAbbuchungsermaechtigung
      ,inserted.strVerwendungszweck1
      ,inserted.strVerwendungszweck2
      ,inserted.strVerwendungszweck3
      ,$action, GETDATE()  
	  into RW_APOBASE_KundeVerbundLog (
	  diKdNr
      ,strVorname
      ,strZwVorname
      ,strName
      ,strTitel
      ,strAnrede
      ,strStrasse
      ,diPlz
      ,strOrt
      ,strPlz
      ,strTelNrP
      ,strTelNrB
      ,strTelNrM
      ,strFaxNr
      ,strEmail
      ,diGebDat
      ,strNotPers
      ,strNotTelNr
      ,bRabattEk
      ,iRabatt
      ,iRabatt2
      ,iRabatt3
      ,iRabatt4
      ,strVersNr
      ,diKKNr
      ,diBefrBisDat
      ,diGltBisDat
      ,diKontakteLJ
      ,diKontakteVJ
      ,cStatus
      ,strIdent
      ,iAnzSubKdn
      ,diInfo
      ,iKuKaNr
      ,cKuKaStat
      ,diKoppelNr
      ,diRefJahr
      ,bMonatsAbr
      ,bQuartAbr
      ,bJahresAbr
      ,bNichtSammel
      ,bNichtEinzel
      ,bAbbuchung
      ,bAllergiker
      ,bKonto
      ,bMed
      ,bNotiz
      ,strHausarzt
      ,strNotiz
      ,strPhonemName
      ,strSuchName
      ,strExtPhonemName
      ,bSchnellerfassung
      ,bytGeschlecht
      ,strInternet
      ,strKKNummer
      ,cOffeneBestellungen
      ,cPostenBotendienst
      ,cPostenNachlieferung
      ,cPostenVorgriff
	  ,diKdNrHpt
      --,diAnzahlSub
      ,bMedNurAkt
      ,bRabInVg
      ,bNoInteraktionsCheck
      ,bHausapotheke
      ,cStdRpStatusInVg
      ,bBefreiungGueltig
      ,diZZLJ
      ,diKdNrRechnung
      ,strZahlungsziel
      ,strBank
      ,strBlz
      ,strKtNr
      ,bFragen1
      ,bFragen2
      ,bFragen3
      ,bFragen4
      ,bJahresrabatt
      ,diBGAPartner
      ,bChargenabfrage
      ,bBonusmodell
      ,bBlister
      ,strPaybackKdNr
      ,bKKNrIsPayback
      ,diAnzeigeGruppe
      ,bGeloescht
      ,bNoHistorie
      ,byDSE
      ,strBIC
      ,strIBAN
      ,strMandatsRefNr
      ,cAbbuchungsermaechtigung
      ,cEinverstaendniserklaerung
      ,dwEinverstaendniserklaerung
      ,dwAbbuchungsermaechtigung
      ,strVerwendungszweck1
      ,strVerwendungszweck2
      ,strVerwendungszweck3
	  ,straction
	  ,diDateTrans);
--Rotation der RW_APOBASE_Verbundlog. Nach 14 Tagen wird gelöscht. Genauer Zeitraum muss noch beobachtet werden
DELETE FROM RW_APOBASE_KundeVerbundlog WHERE DATEDIFF(day, GETDATE(), diDateTrans) > 1; */


exec sp_VerbundKdNrNeu;
/*
-- diKdNrHpt aktualisieren
UPDATE RW_APOBASE_Kunde SET diKdNrHpt = diKdNrAuto 
WHERE diKdNrAuto IN
(SELECT diKdNRAuto FROM RW_APOBASE_Kunde WHERE diKdNr > 0 AND strIdent LIKE 'VerbundApo1' AND diKdNrHpt > 0)

--diKdNrRechnung aktualisieren
UPDATE RW_APOBASE_Kunde SET diKdNrRechnung = diKdNrAuto 
WHERE diKdNrAuto IN
(SELECT diKdNRAuto FROM RW_APOBASE_Kunde WHERE diKdNr > 0 AND strIdent LIKE 'VerbundApo1' AND diKdNrHpt > 0)
*/
--- TODO: Historie im Verbund Mergen ---
/*
Hier ist der Zeitpunkt relevant. 
--> Interessant sind NUR die Datensätze $neuerAlsLetzterAbgleich und $nichtVorhanden
--> Bspw. Die letzten 4 Wochen (Where Quelle.diDate > 20170915)
--> WHEN NOT MATCHED BY  
---> INSERT (alles) VALUES (REMOTEKUNDE.alles) 
ACHTUNG! Hier muss eine Übersetzung der diKdNr auf die NEUE diKdNr des Kunden stattfinden

MERGE   
INTO  RW_APOBASE_Historie AS LOCALHISTORY
USING RW_APOBASE_Historie AS REMOTEHISTORY
ON LOCALHISTORY.Feld = REMOTEHISTORY.Feld AND 
LOCALHISTORY.Feld2 = REMOTEHISTORY.Feld2 --...
WHEN NOT MATCHED BY 
THEN INSERT (*) VALUES (*) -- ....*/

END




GO


