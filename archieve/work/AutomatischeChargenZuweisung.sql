DECLARE @Datum CHAR(8);
DECLARE @CurrentValue NVARCHAR(100);
DECLARE @CurrentDate NVARCHAR(10) = CONVERT(NVARCHAR(8), GETDATE(), 112);

SET @Datum = FORMAT(DATEADD(MONTH, -9, DATEFROMPARTS(YEAR(@CurrentDate), MONTH(@CurrentDate), DAY(@CurrentDate))), 'yyyyMMdd');

SELECT ERezeptID 
  INTO #RezeptRowsCount 
FROM rw_apobase_rezept 
WHERE ERezeptID IS NOT NULL 
  AND diPzn NOT IN ((9999175), (9999637), (9999005), (9999057), (2567024), (6461110), (2567001), (2567018), (8000001), (9999643))
GROUP BY ERezeptID HAVING COUNT(ERezeptID) = 1;

SELECT DISTINCT r.ERezeptID 
	  INTO #Zuweisung 
	FROM RW_APOBASE_Rezept r
	  LEFT JOIN RW_APOBASE_Vorgaenge v ON r.iRpNr = v.iRpNr AND r.diDate = v.diDate
	  LEFT JOIN APO_ABDA_Artikel a ON r.diPzn = a.diPzn
	  LEFT JOIN #RezeptRowsCount rrc ON r.ERezeptID = rrc.ERezeptID
	WHERE v.iRpNr IS NULL 
	  AND a.cRezeptpflicht = 2
	  AND r.bStorno = 0 
	  AND r.iRpNr > 0 
	  AND cFehlerTyp != 5 
	  AND r.ERezeptID IS NOT NULL 
	  AND r.divk != r.diZahlbetrag 
	  AND r.diDate < @CurrentDate;

	DECLARE @Zuweisung_Date NVARCHAR(10) = (SELECT max(didate) FROM RW_APOBASE_Rezept WHERE diDate between (@CurrentDate - 132) AND (@CurrentDate));

	WHILE EXISTS (SELECT TOP 1 ERezeptID FROM #Zuweisung)
		BEGIN
			SELECT TOP 1 @CurrentValue = ERezeptID FROM #Zuweisung;

			DECLARE @Time INT = (SELECT top 1 ditime FROM rw_apobase_rezept WHERE ERezeptID = @CurrentValue);
			DECLARE @VG INT = (SELECT MAX(ivgnr + 1) FROM RW_APOBASE_Vorgaenge WHERE didate = @Zuweisung_Date);
			DECLARE @RP INT = (SELECT MAX(irpnr + 1) FROM rw_apobase_rezept WHERE didate = @Zuweisung_Date);
			DECLARE @PZN INT = (SELECT top 1 dipzn FROM RW_APOBASE_Rezept WHERE ERezeptID = @CurrentValue AND diPzn NOT IN ((9999175), (9999637), (9999005), (9999057), (2567024), (6461110), (2567001), (2567018)))
			DECLARE @Charge nvarchar(25) = (SELECT top 1 s.Charge FROM RW_MODUL_SEC_Securpharm s LEFT JOIN RW_MODUL_SEC_VORGANG_SECURPHARM vs ON s.SecurPharmID = vs.SecurpharmID LEFT JOIN RW_APOBASE_Vorgaenge v ON vs.diDate = v.diDate AND vs.iVgNr = v.iVgNr AND vs.diPzn = v.diPzn WHERE v.diPzn = @PZN AND vs.diDate > @Datum AND s.Charge IS NOT NULL ORDER BY DT DESC);
		
			IF OBJECT_ID('tempdb..#ZuweisungCharge') IS NOT NULL
				drop table #ZuweisungCharge;

				SELECT * INTO #ZuweisungCharge FROM rw_apobase_rezept WHERE ERezeptID = @CurrentValue;
				DELETE FROM RW_APOBASE_Rezept WHERE ERezeptID = @CurrentValue;

				UPDATE #ZuweisungCharge SET irpnr = @RP, diDate = @Zuweisung_Date, diTime = @Time, cKontrollStatus = 0, cFehlerTyp = 0;
		
				INSERT INTO [dbo].[RW_APOBASE_Rezept] ([diDate], [diTime], [iRpNr], [iAnzahl], [diPzn], [strText], [cRpTyp], [cRpStatus], [diVk], [diFbtrg], [diZahlbetrag], [iAnteil], [diZuzahlung], [diKassGrId], [diUserNr], [bStorno], [bAbgelegt], [bEuro], [cKTrg], [bAbdaVCalc], [bKasRab], [bAbdaVStatChg], [cAbdaVAbg], [bEchterZahlbetrag], [diDruckPzn], [iDruckMenge], [bGebucht], [bVorgang], [bRezept], [diKundenNr], [strKundenName], [bAnbieterrabatt], [bApothekenrabatt], [cKassenrabatt], [cAMPreisV_SGB], [cAMPreisV_AMG], [cBedingte_Erstatt_FAM], [cHM_zum_Verbrauch], [cZuzbefreiung_31_SGB], [diApo_Vk_empfohlen], [diAnbieterrabatt], [cRezeptpflicht], [diEk], [diErtrag], [diBGAPartner], [bKndAlternative], [diKombiPzn], [iKombiMenge], [iKombiDefekt], [strPaybackKdNr], [strPaybackMarketingCode], [cPaybackTransaktionsTyp], [diPaybackJobId], [diPaybackTransNr], [diPaybackPunkte], [bPaybackGesendet], [bPaybackOK], [cPositionenTyp], [cUmsatzTyp], [cKasseTyp], [cErtragTyp], [cWoherTyp], [diStornoVerweisNr], [diDruckDatum], [diBedrucktAm], [diDruckUserNr], [bMkvMoeglich], [bMkBefreiung], [cZuzbefreiung_pg_Fbtrg], [diAnbieterrabattGenerikum], [diAnbieterrabattPrsmoratorium], [diKdIkNummer], [diMuster16ID], [strRechenzID], [diLieferID], [cKontrollStatus], [cFehlerTyp], [diTaxEmpf], [strImageFile], [cImageStatus], [diInstanceNr], [diRzptPos], [diFaktorZuzahlung], [cAutIdemAusschluss], [cRv_Ik_Typ], [bStornoKb], [diLfdPRezeptur], [strtransaktionsNummer], [strhashcode], [strerstellungsZeitpunkt], [diPznVerschrieben], [cSubstitutionsgrund], [diZNr], [diEKvID], [cEKvStatus], [cEKvFehler], [strEKvImage], [diZahlbetragKb], [diZahlbetragVg], [strHiMiNr], [bABR302], [diEditVgNr], [diEditVgDatum], [diEditLfdVgNr], [cEditTyp], [strPauschalAbrechnungsNr], [bPauschalAbrechnung], [diFortgesetzteVgNr], [diFortgesetzteVgDatum], [diFortgesetzteLfdVgNr], [cFortgesetzteTyp], [iAnzahlVerschrieben], [strPicNr], [cIstBgSoz], [diBetriebsstaettenNr], [strERezeptId], [strVertragskennzeichen], [cIstFreigegeben], [cKzRueckgabe], [cIstGesperrt], [strPaginiernummer], [strAuftragsnummer], [diTaxe_Soll], [diZahlbetragGes], [diZuzahlungGes], [diEigenanteilGes], [diIndividual_Rabatt], [cPfl_Himi], [ERezeptID], [ERezeptSecret], [Geprueft], [Abgerechnet], [ApoTIZugang], [Markt], [Rabattvertragerfuellung], [PreisguenstigesFAM], [ImportFAM], [Begruendung]) 
				SELECT diDate, diTime, iRpNr, iAnzahl, diPzn, strText, cRpTyp, cRpStatus, diVk, diFbtrg, diZahlbetrag, iAnteil, diZuzahlung, diKassGrId, diUserNr, bStorno, bAbgelegt, bEuro, cKTrg, bAbdaVCalc, bKasRab, bAbdaVStatChg, cAbdaVAbg, bEchterZahlbetrag, diDruckPzn, iDruckMenge, bGebucht, bVorgang, bRezept, diKundenNr, strKundenName, bAnbieterrabatt, bApothekenrabatt, cKassenrabatt, cAMPreisV_SGB, cAMPreisV_AMG, cBedingte_Erstatt_FAM, cHM_zum_Verbrauch, cZuzbefreiung_31_SGB, diApo_Vk_empfohlen, diAnbieterrabatt, cRezeptpflicht, diEk, diErtrag, diBGAPartner, bKndAlternative, diKombiPzn, iKombiMenge, iKombiDefekt, strPaybackKdNr, strPaybackMarketingCode, cPaybackTransaktionsTyp, diPaybackJobId, diPaybackTransNr, diPaybackPunkte, bPaybackGesendet, bPaybackOK, cPositionenTyp, cUmsatzTyp, cKasseTyp, cErtragTyp, cWoherTyp, diStornoVerweisNr, diDruckDatum, diBedrucktAm, diDruckUserNr, bMkvMoeglich, bMkBefreiung, cZuzbefreiung_pg_Fbtrg, diAnbieterrabattGenerikum, diAnbieterrabattPrsmoratorium, diKdIkNummer, diMuster16ID, strRechenzID, diLieferID, cKontrollStatus, cFehlerTyp, diTaxEmpf, strImageFile, cImageStatus, diInstanceNr, diRzptPos, diFaktorZuzahlung, cAutIdemAusschluss, cRv_Ik_Typ, bStornoKb, diLfdPRezeptur, strtransaktionsNummer, strhashcode, strerstellungsZeitpunkt, diPznVerschrieben, cSubstitutionsgrund, diZNr, diEKvID, cEKvStatus, cEKvFehler, strEKvImage, diZahlbetragKb, diZahlbetragVg, strHiMiNr, bABR302, diEditVgNr, diEditVgDatum, diEditLfdVgNr, cEditTyp, strPauschalAbrechnungsNr, bPauschalAbrechnung, diFortgesetzteVgNr, diFortgesetzteVgDatum, diFortgesetzteLfdVgNr, cFortgesetzteTyp, iAnzahlVerschrieben, strPicNr, cIstBgSoz, diBetriebsstaettenNr, strERezeptId, strVertragskennzeichen, cIstFreigegeben, cKzRueckgabe, cIstGesperrt, strPaginiernummer, strAuftragsnummer, diTaxe_Soll, diZahlbetragGes, diZuzahlungGes, diEigenanteilGes, diIndividual_Rabatt, cPfl_Himi, ERezeptID, ERezeptSecret, Geprueft, Abgerechnet, ApoTIZugang, Markt, Rabattvertragerfuellung, PreisguenstigesFAM, ImportFAM, Begruendung
				FROM #ZuweisungCharge WHERE ERezeptID = @CurrentValue;

				INSERT INTO RW_APOBASE_Vorgaenge (diDate, diTime, iVgNr, iRpNr, diPzn, strText) values (@Zuweisung_Date, @Time, @VG, @RP, @PZN, 'Zuweisung')

				UPDATE V 
				SET	V.didate = R.diDate,V.irpnr = R.iRpNr,V.iAnzahl = R.iAnzahl,V.dipzn = R.diPzn,V.ditime = R.diTime,V.strText = R.strtext,V.strKundenName = R.strKundenName ,V.diKundenNr = R.diKundenNr,V.diKdIkNummer = R.diKdIkNummer,V.divk = R.divk,V.diFbtrg = R.diFbtrg,V.diZahlbetrag = R.diZahlbetrag,V.iAnteil = R.iAnteil,V.diZuzahlung = R.diZuzahlung,V.cRpTyp = R.cRpTyp,V.cRpStatus = R.cRpStatus,V.diKassGrId = R.diKassGrId,V.iMwSt = 1900,V.bStorno = R.bStorno,V.bEuro = R.bEuro
				FROM RW_APOBASE_Vorgaenge V INNER JOIN RW_APOBASE_Rezept R ON V.diDate = R.diDate AND V.iRpNr = R.iRpNr
				WHERE V.strText = 'Zuweisung' AND R.ERezeptID = @CurrentValue AND R.diPzn NOT IN ((9999175), (9999637), (9999005), (9999057), (2567024), (6461110), (2567001), (2567018));

					IF (@Charge IS NOT NULL)
					BEGIN
						DECLARE @VGlfd INT = (SELECT top 1 dilfdnr FROM RW_APOBASE_Vorgaenge WHERE diPzn = @PZN AND diDate = @Zuweisung_Date AND iVgNr = @VG AND iRpNr = @RP);

						INSERT INTO RW_MODUL_SEC_VORGANG_SECURPHARM(dilfdnr, SecurpharmID, iVgNr, didate, diPzn)
						values (@VGlfd, @CurrentValue, @VG, @Zuweisung_Date, @PZN)

						INSERT INTO RW_MODUL_SEC_Securpharm (SecurPharmID, Charge, SN, Verfall)
						values (@CurrentValue, @Charge, 'Automatisch', 99998877)
					END

				DELETE FROM RW_EREZEPT_Abrechnung WHERE ERezeptID = @CurrentValue;
				UPDATE RW_APOBASE_Rezept SET cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID = @CurrentValue; 

			DELETE FROM #Zuweisung WHERE ERezeptID = @CurrentValue;
		END


IF OBJECT_ID('tempdb..#Zuweisung') IS NOT NULL 
	DROP TABLE #Zuweisung;
IF OBJECT_ID('tempdb..#RezeptRowsCount') IS NOT NULL 
	DROP TABLE #RezeptRowsCount;
