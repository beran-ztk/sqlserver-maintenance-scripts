Use Apobase
GO

CREATE PROCEDURE AutomatischeZuweisung
AS
BEGIN

DECLARE @CurrentValue NVARCHAR(25);
DECLARE @CurrentDate NVARCHAR(10) = dbo.date();

--Nicht Hochgeladene ERezept mit nur einem Medikamentposten
SELECT ERezeptID
  INTO #RezeptRowsCount 
FROM rw_apobase_rezept 
WHERE diPzn NOT IN ((9999175), (9999637), (9999005), (9999057), (2567024), (6461110), (2567001), (2567018), (8000001), (9999643))
  AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ERezeptID IS NOT NULL AND bStorno = 0 AND iRpNr > 0 AND divk != diZahlbetrag AND NOT (cKontrollStatus = 2 AND cFehlerTyp = 5)) 
GROUP BY ERezeptID HAVING COUNT(ERezeptID) = 1;

--ERezepte aus #RezeptRowsCount ohne einen Vorgang
SELECT DISTINCT(r.ERezeptID) 
	  INTO #Zuweisung 
	FROM RW_APOBASE_Rezept r
	  INNER JOIN #RezeptRowsCount rc ON r.ERezeptID = rc.ERezeptID
	  LEFT JOIN RW_APOBASE_Vorgaenge v ON r.iRpNr = v.iRpNr AND r.diDate = v.diDate
	WHERE v.iRpNr IS NULL;

	--Das höchst nutzbare Datum bis maximal heute, da die Apotheke beispielweise länger zu haben könnte und das Skript erst in den Folgetagen durchlief etc.
	DECLARE @ZuweisungsDatum NVARCHAR(10) = (SELECT max(didate) FROM RW_APOBASE_Rezept WHERE diDate <= dbo.date());

	WHILE EXISTS (SELECT TOP 1 ERezeptID FROM #Zuweisung)
		BEGIN
			SELECT TOP 1 @CurrentValue = ERezeptID FROM #Zuweisung;

			--Die nächste Vorgangs und Rezeptnummer aus dem neuen Zuweisungsdatum
			DECLARE @RP INT = (SELECT MAX(irpnr + 1) FROM RW_APOBASE_Rezept WHERE didate = @ZuweisungsDatum);
			DECLARE @VG INT = (SELECT MAX(ivgnr + 1) FROM RW_APOBASE_Vorgaenge WHERE didate = @ZuweisungsDatum);
			DECLARE @Time INT = (SELECT TOP 1 ditime FROM RW_APOBASE_Rezept WHERE ERezeptID = @CurrentValue);
			DECLARE @PZN INT = (SELECT TOP 1 dipzn FROM RW_APOBASE_Rezept WHERE ERezeptID = @CurrentValue AND diPzn NOT IN ((9999175), (9999637), (9999005), (9999057), (2567024), (6461110), (2567001), (2567018), (8000001), (9999643)));

				--Eine Vollständige Kopie des ERezeptes erstellen um diesen zu manipulieren
				SELECT * INTO #ERezeptKopie FROM rw_apobase_rezept WHERE ERezeptID = @CurrentValue;
				--Das eigentliche ERezept vollständig löschen
				DELETE FROM RW_APOBASE_Rezept WHERE ERezeptID = @CurrentValue;

				--Select ERezeptCopy für Powershell 
				SELECT ERezeptID, diDate, diTime, iRpNr, @ZuweisungsDatum AS ZuweisungsDatum, @Time AS ZuweisungsZeit, @VG AS ZuweisungsVorgang, @RP AS ZuweisungsRezept from #ERezeptKopie 

				--Manipuliere ERezeptdaten
				UPDATE #ERezeptKopie SET irpnr = @RP, diDate = @ZuweisungsDatum, diTime = @Time, cKontrollStatus = 0, cFehlerTyp = 0;
		
				--Insert manipuliertes ERezept in die Rezepttabelle
				INSERT INTO [dbo].[RW_APOBASE_Rezept] ([diDate], [diTime], [iRpNr], [iAnzahl], [diPzn], [strText], [cRpTyp], [cRpStatus], [diVk], [diFbtrg], [diZahlbetrag], [iAnteil], [diZuzahlung], [diKassGrId], [diUserNr], [bStorno], [bAbgelegt], [bEuro], [cKTrg], [bAbdaVCalc], [bKasRab], [bAbdaVStatChg], [cAbdaVAbg], [bEchterZahlbetrag], [diDruckPzn], [iDruckMenge], [bGebucht], [bVorgang], [bRezept], [diKundenNr], [strKundenName], [bAnbieterrabatt], [bApothekenrabatt], [cKassenrabatt], [cAMPreisV_SGB], [cAMPreisV_AMG], [cBedingte_Erstatt_FAM], [cHM_zum_Verbrauch], [cZuzbefreiung_31_SGB], [diApo_Vk_empfohlen], [diAnbieterrabatt], [cRezeptpflicht], [diEk], [diErtrag], [diBGAPartner], [bKndAlternative], [diKombiPzn], [iKombiMenge], [iKombiDefekt], [strPaybackKdNr], [strPaybackMarketingCode], [cPaybackTransaktionsTyp], [diPaybackJobId], [diPaybackTransNr], [diPaybackPunkte], [bPaybackGesendet], [bPaybackOK], [cPositionenTyp], [cUmsatzTyp], [cKasseTyp], [cErtragTyp], [cWoherTyp], [diStornoVerweisNr], [diDruckDatum], [diBedrucktAm], [diDruckUserNr], [bMkvMoeglich], [bMkBefreiung], [cZuzbefreiung_pg_Fbtrg], [diAnbieterrabattGenerikum], [diAnbieterrabattPrsmoratorium], [diKdIkNummer], [diMuster16ID], [strRechenzID], [diLieferID], [cKontrollStatus], [cFehlerTyp], [diTaxEmpf], [strImageFile], [cImageStatus], [diInstanceNr], [diRzptPos], [diFaktorZuzahlung], [cAutIdemAusschluss], [cRv_Ik_Typ], [bStornoKb], [diLfdPRezeptur], [strtransaktionsNummer], [strhashcode], [strerstellungsZeitpunkt], [diPznVerschrieben], [cSubstitutionsgrund], [diZNr], [diEKvID], [cEKvStatus], [cEKvFehler], [strEKvImage], [diZahlbetragKb], [diZahlbetragVg], [strHiMiNr], [bABR302], [diEditVgNr], [diEditVgDatum], [diEditLfdVgNr], [cEditTyp], [strPauschalAbrechnungsNr], [bPauschalAbrechnung], [diFortgesetzteVgNr], [diFortgesetzteVgDatum], [diFortgesetzteLfdVgNr], [cFortgesetzteTyp], [iAnzahlVerschrieben], [strPicNr], [cIstBgSoz], [diBetriebsstaettenNr], [strERezeptId], [strVertragskennzeichen], [cIstFreigegeben], [cKzRueckgabe], [cIstGesperrt], [strPaginiernummer], [strAuftragsnummer], [diTaxe_Soll], [diZahlbetragGes], [diZuzahlungGes], [diEigenanteilGes], [diIndividual_Rabatt], [cPfl_Himi], [ERezeptID], [ERezeptSecret], [Geprueft], [Abgerechnet], [ApoTIZugang], [Markt], [Rabattvertragerfuellung], [PreisguenstigesFAM], [ImportFAM], [Begruendung]) 
				SELECT diDate, diTime, iRpNr, iAnzahl, diPzn, strText, cRpTyp, cRpStatus, diVk, diFbtrg, diZahlbetrag, iAnteil, diZuzahlung, diKassGrId, diUserNr, bStorno, bAbgelegt, bEuro, cKTrg, bAbdaVCalc, bKasRab, bAbdaVStatChg, cAbdaVAbg, bEchterZahlbetrag, diDruckPzn, iDruckMenge, bGebucht, bVorgang, bRezept, diKundenNr, strKundenName, bAnbieterrabatt, bApothekenrabatt, cKassenrabatt, cAMPreisV_SGB, cAMPreisV_AMG, cBedingte_Erstatt_FAM, cHM_zum_Verbrauch, cZuzbefreiung_31_SGB, diApo_Vk_empfohlen, diAnbieterrabatt, cRezeptpflicht, diEk, diErtrag, diBGAPartner, bKndAlternative, diKombiPzn, iKombiMenge, iKombiDefekt, strPaybackKdNr, strPaybackMarketingCode, cPaybackTransaktionsTyp, diPaybackJobId, diPaybackTransNr, diPaybackPunkte, bPaybackGesendet, bPaybackOK, cPositionenTyp, cUmsatzTyp, cKasseTyp, cErtragTyp, cWoherTyp, diStornoVerweisNr, diDruckDatum, diBedrucktAm, diDruckUserNr, bMkvMoeglich, bMkBefreiung, cZuzbefreiung_pg_Fbtrg, diAnbieterrabattGenerikum, diAnbieterrabattPrsmoratorium, diKdIkNummer, diMuster16ID, strRechenzID, diLieferID, cKontrollStatus, cFehlerTyp, diTaxEmpf, strImageFile, cImageStatus, diInstanceNr, diRzptPos, diFaktorZuzahlung, cAutIdemAusschluss, cRv_Ik_Typ, bStornoKb, diLfdPRezeptur, strtransaktionsNummer, strhashcode, strerstellungsZeitpunkt, diPznVerschrieben, cSubstitutionsgrund, diZNr, diEKvID, cEKvStatus, cEKvFehler, strEKvImage, diZahlbetragKb, diZahlbetragVg, strHiMiNr, bABR302, diEditVgNr, diEditVgDatum, diEditLfdVgNr, cEditTyp, strPauschalAbrechnungsNr, bPauschalAbrechnung, diFortgesetzteVgNr, diFortgesetzteVgDatum, diFortgesetzteLfdVgNr, cFortgesetzteTyp, iAnzahlVerschrieben, strPicNr, cIstBgSoz, diBetriebsstaettenNr, strERezeptId, strVertragskennzeichen, cIstFreigegeben, cKzRueckgabe, cIstGesperrt, strPaginiernummer, strAuftragsnummer, diTaxe_Soll, diZahlbetragGes, diZuzahlungGes, diEigenanteilGes, diIndividual_Rabatt, cPfl_Himi, ERezeptID, ERezeptSecret, Geprueft, Abgerechnet, ApoTIZugang, Markt, Rabattvertragerfuellung, PreisguenstigesFAM, ImportFAM, Begruendung
				FROM #ERezeptKopie WHERE ERezeptID = @CurrentValue;

				--Erstellt ein Vorgang basierend auf den Rezeptdaten
				INSERT INTO RW_APOBASE_Vorgaenge (diDate, diTime, iVgNr, iRpNr, diPzn, strText) VALUES (@ZuweisungsDatum, @Time, @VG, @RP, @PZN, 'Zuweisung')

				--Update diesen Vorgang, ist einfach in 2 Schritten, um erstmal die Columns not null zu füllen
				UPDATE V 
				SET	V.didate = R.diDate,V.irpnr = R.iRpNr,V.iAnzahl = R.iAnzahl,V.dipzn = R.diPzn,V.ditime = R.diTime,V.strText = R.strtext,V.strKundenName = R.strKundenName ,V.diKundenNr = R.diKundenNr,V.diKdIkNummer = R.diKdIkNummer,V.divk = R.divk,V.diFbtrg = R.diFbtrg,V.diZahlbetrag = R.diZahlbetrag,V.iAnteil = R.iAnteil,V.diZuzahlung = R.diZuzahlung,V.cRpTyp = R.cRpTyp,V.cRpStatus = R.cRpStatus,V.diKassGrId = R.diKassGrId,V.iMwSt = 1900,V.bStorno = R.bStorno,V.bEuro = R.bEuro
				FROM RW_APOBASE_Vorgaenge V INNER JOIN RW_APOBASE_Rezept R ON V.diDate = R.diDate AND V.iRpNr = R.iRpNr
				WHERE V.strText = 'Zuweisung' AND R.ERezeptID = @CurrentValue AND R.diPzn NOT IN ((9999175), (9999637), (9999005), (9999057), (2567024), (6461110), (2567001), (2567018), (8000001), (9999643));

				DELETE FROM RW_EREZEPT_Abrechnung WHERE ERezeptID = @CurrentValue;				

				IF OBJECT_ID('tempdb..#ERezeptKopie') IS NOT NULL
				drop table #ERezeptKopie;

			DELETE FROM #Zuweisung WHERE ERezeptID = @CurrentValue;
		END


IF OBJECT_ID('tempdb..#Zuweisung') IS NOT NULL 
	DROP TABLE #Zuweisung;
IF OBJECT_ID('tempdb..#RezeptRowsCount') IS NOT NULL 
	DROP TABLE #RezeptRowsCount;

END