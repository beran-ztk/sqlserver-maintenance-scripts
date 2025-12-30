DECLARE @Datum CHAR(8), @Heute DATE = GETDATE();

	IF DAY(@Heute) < 15
		SET @Datum = FORMAT(DATEFROMPARTS(YEAR(@Heute), MONTH(@Heute), 1), 'yyyyMMdd');
	ELSE
		SET @Datum = FORMAT(DATEFROMPARTS(YEAR(@Heute), MONTH(@Heute), 15), 'yyyyMMdd');

DECLARE @CurrentDate NVARCHAR(10) = CONVERT(NVARCHAR(8), GETDATE(), 112);
DECLARE @CurrentDateValue NVARCHAR(10) = SUBSTRING(CONVERT(VARCHAR(10), @CurrentDate), 0, 5) + '-' + SUBSTRING(CONVERT(VARCHAR(10), @CurrentDate), 5, 2) + '-' + SUBSTRING(CONVERT(VARCHAR(10), @CurrentDate), 7, 2);

	SELECT DISTINCT(ERezeptID) INTO #ErrorRows FROM RW_APOBASE_Rezept WHERE cKontrollStatus IN (3,4) AND ERezeptID IS NOT NULL AND bstorno = 0 AND iRpNr > 0;
	SELECT dilfdnr INTO #PZN FROM rw_apobase_rezept WHERE ERezeptID IS NOT NULL AND diPzn IN ((9999175), (9999637), (9999005), (9999057), (2567024), (6461110), (2567001), (2567018), (8000001), (9999643));
	SELECT ERezeptID INTO #RezeptRowsCount FROM rw_apobase_rezept WHERE ERezeptID IS NOT NULL AND diLfdNr NOT IN (SELECT diLfdNr FROM #PZN) GROUP BY ERezeptID HAVING COUNT(ERezeptID) = 1;

--=======================================Clear=======================================--
	select ERezeptID into #x from ERezeptView where didate > 20250414 and iRpNr > 0 and bStorno = 0 and cast(Abrechnung as nvarchar(max)) like '%e|1.3%' 
	update RW_APOBASE_Rezept set cKontrollStatus = 0, cFehlerTyp = 0 where ERezeptID in (select ERezeptID from #x)
	delete RW_EREZEPT_Abrechnung where ERezeptID in (select ERezeptID from #x)
	delete RW_EREZEPT_RZErgebnis where ERezeptID in (select ERezeptID from #x)
	drop table #x

	SELECT DISTINCT(ERezeptID) INTO #KR FROM RW_APOBASE_Rezept WHERE cKontrollStatus IN (4) AND iRpNr > 0 AND bStorno = 0 AND ERezeptID IN (SELECT ERezeptID FROM RW_EREZEPT_RZErgebnis WHERE Kommentar LIKE '%fhir%');DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT ERezeptID FROM #KR);DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT ERezeptID FROM #KR);UPDATE RW_APOBASE_Rezept SET cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT ERezeptID FROM #KR);DROP TABLE #KR;
	
	DELETE RW_EREZEPT_RZErgebnis WHERE status = 'Hinweis' AND Kommentar LIKE '%vsys-004%';
	DELETE RW_EREZEPT_RZErgebnis WHERE status = 'Hinweis' AND Kommentar like '%Arzt%Betriebsstätte%' AND ERezeptID IN (SELECT ERezeptID FROM RW_EREZEPT_RZErgebnis WHERE Kommentar like '%LANR%');
	DELETE RW_EREZEPT_RZErgebnis WHERE status = 'Hinweis' AND Kommentar like '%Packungsgröße%' AND ERezeptID IN (SELECT ERezeptID FROM RW_EREZEPT_RZErgebnis WHERE Kommentar like '%apothekenpflichtigen%Papierrezept%');
	DELETE RW_EREZEPT_RZErgebnis where ERezeptID in (select ERezeptID from RW_APOBASE_Rezept where cKontrollStatus IN (0,2) or iRpNr = 0 or bstorno = 1);

	DELETE RW_EREZEPT_RZErgebnis where ERezeptID in (select ERezeptID from RW_APOBASE_Rezept where cKontrollStatus != 2 and ERezeptID is not null and bStorno = 0 and iRpNr > 0 and Markt = 1 and Rabattvertragerfuellung = 0 and PreisguenstigesFAM = 0 and ImportFAM in (0,5))
	UPDATE RW_APOBASE_Rezept set Markt = 1, Rabattvertragerfuellung = 1, PreisguenstigesFAM = 0, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0 where ERezeptID in (select ERezeptID from RW_APOBASE_Rezept where cKontrollStatus != 2 and ERezeptID is not null and bStorno = 0 and iRpNr > 0 and Markt = 1 and Rabattvertragerfuellung = 0 and PreisguenstigesFAM = 0 and ImportFAM in (0,5))

--=======================================NullRezept=======================================--
SELECT distinct(r.ERezeptID) INTO #Selbstzahler 
	FROM RW_APOBASE_Rezept r
	INNER JOIN RW_APOBASE_Rezept sub ON r.ERezeptID = sub.ERezeptID
	INNER JOIN #ErrorRows er ON r.ERezeptID = er.ERezeptID
	INNER JOIN #RezeptRowsCount rc ON r.ERezeptID = rc.ERezeptID
		WHERE sub.diVk = sub.diZahlbetrag AND sub.diVk BETWEEN 1 AND 3000 AND sub.diLfdNr NOT IN (SELECT diLfdNr FROM #PZN)
		   OR r.ERezeptID IN (SELECT ERezeptID FROM RW_EREZEPT_RZErgebnis WHERE Kommentar LIKE '%Kassenart%nicht%zugelassen%' OR Kommentar like '%Selbstzahler%' OR Kommentar like '%(Nullerrezept%');

DELETE RW_EREZEPT_RZErgebnis where erezeptid in (select erezeptid from #Selbstzahler)
UPDATE RW_APOBASE_Rezept SET cKontrollStatus = 2, cFehlerTyp = 5, cRpStatus = 5 where erezeptid in (select erezeptid from #Selbstzahler)

--=======================================Markt>=3=======================================--
SELECT * INTO #e FROM RW_APOBASE_Rezept WHERE ERezeptID IS NOT NULL AND cKontrollStatus != 2 AND iRpNr > 0 AND bStorno = 0;

SELECT ERezeptID INTO #Mehrfachbetrieb FROM RW_APOBASE_Rezept INNER JOIN APO_ABDA_PAC_APO ON diPzn = PZN WHERE Markt != 3 AND Ausnahme_Ersetzung = 1 and MV_Gruppe > 0 AND ERezeptID IN (SELECT ERezeptID FROM #e);
SELECT ERezeptID INTO #AutIdem from RW_APOBASE_Rezept where cAutIdemAusschluss in (2,4) AND Markt != 4 AND ERezeptID IN (SELECT ERezeptID FROM #e);
SELECT ERezeptID INTO #Ausschluss FROM RW_APOBASE_Rezept INNER JOIN APO_ABDA_PAC_APO ON diPzn = PZN WHERE Markt != 5 AND Ausnahme_Ersetzung = 1 AND ERezeptID IN (SELECT ERezeptID FROM #e); 

SELECT distinct(r.ERezeptID),diPzn,diKdIkNummer INTO #Rabattvertrag 
FROM RW_APOBASE_Rezept r
INNER JOIN #RezeptRowsCount rc ON r.ERezeptID = rc.ERezeptID
	WHERE r.ERezeptID IS NOT NULL AND cKontrollStatus != 2 AND iRpNr > 0 AND bStorno = 0 AND didate > @Datum
	  AND r.diPzn NOT IN ((9999175), (9999637), (9999005), (9999057), (2567024), (6461110), (2567001), (2567018), (8000001), (9999643));
--3
UPDATE RW_APOBASE_Rezept SET Markt = 3, Rabattvertragerfuellung = 1, PreisguenstigesFAM = 0, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0
FROM RW_APOBASE_Rezept INNER JOIN APO_ABDA_PAC_APO ON diPzn = PZN WHERE ERezeptID IN (SELECT ERezeptID FROM #Mehrfachbetrieb) AND ERezeptID IN (Select ERezeptID from RW_EREZEPT_RZErgebnis where Kurztext like '%rabattvertrag%ist ein vertragsartikel%');
--4
UPDATE RW_APOBASE_Rezept SET Markt = 4, Rabattvertragerfuellung = 1, PreisguenstigesFAM = 0, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0
FROM RW_APOBASE_Rezept INNER JOIN APO_ABDA_PAC_APO ON diPzn = PZN WHERE ERezeptID IN (SELECT ERezeptID FROM #AutIdem) AND ERezeptID IN (Select ERezeptID from RW_EREZEPT_RZErgebnis where Kurztext like '%rabattvertrag%ist ein vertragsartikel%');
--5
UPDATE RW_APOBASE_Rezept SET Markt = 5, Rabattvertragerfuellung = 1, PreisguenstigesFAM = 0, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0
FROM RW_APOBASE_Rezept INNER JOIN APO_ABDA_PAC_APO ON diPzn = PZN WHERE ERezeptID IN (SELECT ERezeptID FROM #Ausschluss) AND ERezeptID IN (Select ERezeptID from RW_EREZEPT_RZErgebnis where Kurztext like '%rabattvertrag%ist ein vertragsartikel%');

--3
UPDATE RW_APOBASE_Rezept SET Markt = 3, Rabattvertragerfuellung = 2, PreisguenstigesFAM = 0, ImportFAM = 5, cKontrollStatus = 0, cFehlerTyp = 0
FROM RW_APOBASE_Rezept INNER JOIN APO_ABDA_PAC_APO ON diPzn = PZN WHERE ERezeptID IN (SELECT ERezeptID FROM #Mehrfachbetrieb) AND ERezeptID IN (Select ERezeptID from RW_EREZEPT_RZErgebnis where Kurztext like '%rabattvertrag%ist kein vertragsartikel%');
--4
UPDATE RW_APOBASE_Rezept SET Markt = 4, Rabattvertragerfuellung = 2, PreisguenstigesFAM = 0, ImportFAM = 5, cKontrollStatus = 0, cFehlerTyp = 0
FROM RW_APOBASE_Rezept INNER JOIN APO_ABDA_PAC_APO ON diPzn = PZN WHERE ERezeptID IN (SELECT ERezeptID FROM #AutIdem) AND ERezeptID IN (Select ERezeptID from RW_EREZEPT_RZErgebnis where Kurztext like '%rabattvertrag%ist kein vertragsartikel%');
--5
UPDATE RW_APOBASE_Rezept SET Markt = 5, Rabattvertragerfuellung = 2, PreisguenstigesFAM = 0, ImportFAM = 5, cKontrollStatus = 0, cFehlerTyp = 0
FROM RW_APOBASE_Rezept INNER JOIN APO_ABDA_PAC_APO ON diPzn = PZN WHERE ERezeptID IN (SELECT ERezeptID FROM #Ausschluss) AND ERezeptID IN (Select ERezeptID from RW_EREZEPT_RZErgebnis where Kurztext like '%rabattvertrag%ist kein vertragsartikel%');

--3
UPDATE RW_APOBASE_Rezept SET Markt = 3, Rabattvertragerfuellung = 0, PreisguenstigesFAM = 0, ImportFAM = 5, cKontrollStatus = 0, cFehlerTyp = 0
FROM RW_APOBASE_Rezept INNER JOIN APO_ABDA_PAC_APO ON diPzn = PZN WHERE ERezeptID IN (SELECT ERezeptID FROM #Mehrfachbetrieb) AND NOT ERezeptID IN (Select ERezeptID from RW_EREZEPT_RZErgebnis where Kurztext like '%rabattvertrag%ist ein vertragsartikel%' OR Kurztext like '%rabattvertrag%ist kein vertragsartikel%');
--4
UPDATE RW_APOBASE_Rezept SET Markt = 4, Rabattvertragerfuellung = 0, PreisguenstigesFAM = 0, ImportFAM = 5, cKontrollStatus = 0, cFehlerTyp = 0
FROM RW_APOBASE_Rezept INNER JOIN APO_ABDA_PAC_APO ON diPzn = PZN WHERE ERezeptID IN (SELECT ERezeptID FROM #AutIdem) AND NOT ERezeptID IN (Select ERezeptID from RW_EREZEPT_RZErgebnis where Kurztext like '%rabattvertrag%ist ein vertragsartikel%' OR Kurztext like '%rabattvertrag%ist kein vertragsartikel%');
--5
UPDATE RW_APOBASE_Rezept SET Markt = 5, Rabattvertragerfuellung = 0, PreisguenstigesFAM = 0, ImportFAM = 5, cKontrollStatus = 0, cFehlerTyp = 0
FROM RW_APOBASE_Rezept INNER JOIN APO_ABDA_PAC_APO ON diPzn = PZN WHERE ERezeptID IN (SELECT ERezeptID FROM #Ausschluss) AND NOT ERezeptID IN (Select ERezeptID from RW_EREZEPT_RZErgebnis where Kurztext like '%rabattvertrag%ist ein vertragsartikel%' OR Kurztext like '%rabattvertrag%ist kein vertragsartikel%');

DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT ERezeptID FROM #Mehrfachbetrieb) OR ERezeptID IN (SELECT ERezeptID FROM #AutIdem) OR ERezeptID IN (SELECT ERezeptID FROM #Ausschluss)
DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT ERezeptID FROM #Mehrfachbetrieb) OR ERezeptID IN (SELECT ERezeptID FROM #AutIdem) OR ERezeptID IN (SELECT ERezeptID FROM #Ausschluss)
drop table #Mehrfachbetrieb; drop table #AutIdem; drop table #Ausschluss;

--=======================================Rabattvertrag=======================================--
DECLARE @ERezeptRabattvertrag NVARCHAR(25);
DECLARE RabattCursor CURSOR FOR 
	SELECT ERezeptID FROM #Rabattvertrag;

OPEN RabattCursor;
FETCH NEXT FROM RabattCursor INTO @ERezeptRabattvertrag;

WHILE @@FETCH_STATUS = 0
	BEGIN
		Declare @ik int, @pzn int;
		SET @ik = (select diKdIkNummer from #Rabattvertrag where ERezeptID = @ERezeptRabattvertrag);
		SET @pzn = (select diPzn from #Rabattvertrag where ERezeptID = @ERezeptRabattvertrag);

			IF (dbo.Ist_Rabattvertrag_vorhanden(@ik, @pzn) > 0)
				BEGIN
					DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID = @ERezeptRabattvertrag;
					DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID = @ERezeptRabattvertrag;
					UPDATE RW_APOBASE_Rezept SET cKontrollStatus = 0, cFehlerTyp = 0, Rabattvertragerfuellung = 1, PreisguenstigesFAM = 0, ImportFAM = 0 WHERE ERezeptID = @ERezeptRabattvertrag;
				END

		FETCH NEXT FROM RabattCursor INTO @ERezeptRabattvertrag;
	END

CLOSE RabattCursor;
DEALLOCATE RabattCursor;

--=======================================Sonderkennzeichen=======================================--
SELECT DISTINCT(ERezeptID) AS E INTO #T1 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ((markt = 0) OR (markt = 1 AND ImportFAM != 0) OR (markt = 1 AND Rabattvertragerfuellung = 0 AND PreisguenstigesFAM = 0));

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T1);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T1);
UPDATE RW_APOBASE_Rezept SET markt = 1, Rabattvertragerfuellung = 1, PreisguenstigesFAM = 0, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T1);
DROP TABLE #T1;	
-----------------
SELECT DISTINCT(ERezeptID) AS E INTO #T2 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 211 AND markt = 1)
AND NOT (Rabattvertragerfuellung = 2 AND PreisguenstigesFAM = 1);

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T2);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T2);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 2, PreisguenstigesFAM = 1, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T2);
DROP TABLE #T2;
----
SELECT DISTINCT(ERezeptID) AS E INTO #T3 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 211 AND markt != 1)
AND NOT (Rabattvertragerfuellung = 2 AND PreisguenstigesFAM = 0 AND ImportFAM IN (1,5));

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T3);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T3);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 2, PreisguenstigesFAM = 0, ImportFAM = 5, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T3);
DROP TABLE #T3;
-----------------
SELECT DISTINCT(ERezeptID) AS E INTO #T4 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 311 AND markt = 1)
AND NOT (Rabattvertragerfuellung = 0 AND PreisguenstigesFAM = 2 AND ImportFAM = 0);

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T4);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T4);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 0, PreisguenstigesFAM = 2, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T4);
DROP TABLE #T4;
----
SELECT DISTINCT(ERezeptID) AS E INTO #T5 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 311 AND markt != 1)
AND NOT (Rabattvertragerfuellung = 0 AND PreisguenstigesFAM = 0 AND ImportFAM = 2);

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T5);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T5);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 0, PreisguenstigesFAM = 0, ImportFAM = 2, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T5);
DROP TABLE #T5;
-----------------
SELECT DISTINCT(ERezeptID) AS E INTO #T6 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 411 AND markt = 1)
AND NOT (Rabattvertragerfuellung = 2 AND PreisguenstigesFAM = 2 AND ImportFAM = 0);

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T6);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T6);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 2, PreisguenstigesFAM = 2, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T6);
DROP TABLE #T6;
----
SELECT DISTINCT(ERezeptID) AS E INTO #T7 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 411 AND markt != 1)
AND NOT (Rabattvertragerfuellung = 2 AND PreisguenstigesFAM = 0 AND ImportFAM = 2);

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T7);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T7);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 2, PreisguenstigesFAM = 0, ImportFAM = 2, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T7);
DROP TABLE #T7;
-----------------
SELECT DISTINCT(ERezeptID) AS E INTO #T8 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 511 AND markt = 1)
AND NOT (Rabattvertragerfuellung = 3 AND PreisguenstigesFAM = 1 AND ImportFAM = 0);

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T8);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T8);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 3, PreisguenstigesFAM = 1, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T8);
DROP TABLE #T8;
----
SELECT DISTINCT(ERezeptID) AS E INTO #T9 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 511 AND markt != 1)
AND NOT (Rabattvertragerfuellung = 3 AND PreisguenstigesFAM = 0 AND ImportFAM = 5);

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T9);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T9);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 3, PreisguenstigesFAM = 0, ImportFAM = 5, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T9);
DROP TABLE #T9;
-----------------
SELECT DISTINCT(ERezeptID) AS E INTO #T10 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 611 AND markt = 1)
AND NOT (Rabattvertragerfuellung IN (0,2,3) AND PreisguenstigesFAM = 3 AND ImportFAM = 0)
AND NOT (Rabattvertragerfuellung = 3 AND PreisguenstigesFAM IN (2,3,4) AND ImportFAM = 0);

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T10);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T10);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 3, PreisguenstigesFAM = 3, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T10);
DROP TABLE #T10;
----
SELECT DISTINCT(ERezeptID) AS E INTO #T11 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 611 AND markt != 1)
AND NOT (Rabattvertragerfuellung IN (0,2) AND PreisguenstigesFAM = 0 AND ImportFAM = 3)
AND NOT (Rabattvertragerfuellung = 3 AND PreisguenstigesFAM = 0 AND ImportFAM IN (2, 3, 4));

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T11);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T11);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 3, PreisguenstigesFAM = 0, ImportFAM = 3, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T11);
DROP TABLE #T11;
-----------------
SELECT DISTINCT(ERezeptID) AS E INTO #T12 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 811 AND markt = 1)
AND NOT (Rabattvertragerfuellung = 4 AND PreisguenstigesFAM = 1 AND ImportFAM = 0);

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T12);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T12);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 4, PreisguenstigesFAM = 1, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T12);
DROP TABLE #T12;
----
SELECT DISTINCT(ERezeptID) AS E INTO #T13 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 811 AND markt != 1)
AND NOT (Rabattvertragerfuellung = 4 AND PreisguenstigesFAM = 0 AND ImportFAM IN (1,5));

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T13);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T13);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 4, PreisguenstigesFAM = 0, ImportFAM = 5, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T13);
DROP TABLE #T13;
-----------------
SELECT DISTINCT(ERezeptID) AS E INTO #T14 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 911 AND markt = 1)
AND NOT (Rabattvertragerfuellung IN (0,2,4) AND PreisguenstigesFAM = 4 AND ImportFAM = 0)
AND NOT (Rabattvertragerfuellung = 4 AND PreisguenstigesFAM IN (2,3) AND ImportFAM = 0);

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T14);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T14);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 4, PreisguenstigesFAM = 4, ImportFAM = 0, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T14);
DROP TABLE #T14;		
----
SELECT DISTINCT(ERezeptID) AS E INTO #T15 FROM RW_APOBASE_Rezept WHERE ERezeptID IN (SELECT ERezeptID from #ErrorRows)
AND ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE ianzahl = 911 AND markt != 1)
AND NOT (Rabattvertragerfuellung IN (0,2) AND PreisguenstigesFAM = 0 AND ImportFAM = 4)
AND NOT (Rabattvertragerfuellung = 4 AND PreisguenstigesFAM = 0 AND ImportFAM IN (2,3,4));

DELETE RW_EREZEPT_Abrechnung WHERE ERezeptID IN (SELECT E FROM #T15);
DELETE RW_EREZEPT_RZErgebnis WHERE ERezeptID IN (SELECT E FROM #T15);
UPDATE RW_APOBASE_Rezept SET Rabattvertragerfuellung = 4, PreisguenstigesFAM = 0, ImportFAM = 4, cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID IN (SELECT E FROM #T15);
DROP TABLE #T15;

DROP TABLE #e
DROP TABLE #PZN
DROP TABLE #RezeptRowsCount
DROP TABLE #Selbstzahler
DROP TABLE #ErrorRows
DROP TABLE #Rabattvertrag


DECLARE @E TABLE (ERezeptID NVARCHAR(25));

INSERT INTO @E (ERezeptID)
SELECT DISTINCT ERezeptID 
FROM RW_EREZEPT_RZErgebnis 
WHERE Kommentar LIKE '%gültig%' OR Kommentar LIKE '%Datum%' OR Kommentar LIKE '%Ablauf%' OR Kommentar LIKE '%Zeit%' OR Kommentar LIKE '%Frist%' OR Kommentar LIKE '%abgabefrist%' 
AND NOT ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE cKontrollStatus = 2 and ERezeptID IS NOT NULL AND bStorno = 0);

DECLARE @CurrentERezeptID NVARCHAR(25);

DECLARE ERezeptID_Cursor CURSOR FOR
SELECT ERezeptID FROM @E;

OPEN ERezeptID_Cursor;
FETCH NEXT FROM ERezeptID_Cursor INTO @CurrentERezeptID;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @AccepptDate XML, 
            @WhenHandenOver XML,
            @AccepptDateValue NVARCHAR(25), 
            @WhenHandedOverValue NVARCHAR(25),
            @AccepptDateValueOriginal NVARCHAR(25); 

    SELECT @AccepptDate = Blob FROM RW_EREZEPT_Verordnung WHERE ERezeptID = @CurrentERezeptID;
    SELECT @WhenHandenOver = Blob FROM RW_EREZEPT_Abrechnung WHERE ERezeptID = @CurrentERezeptID;

    ;WITH XMLNAMESPACES(DEFAULT 'http://hl7.org/fhir')
    SELECT @AccepptDateValue = @AccepptDate.value('(//extension[@url=''https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_AcceptDate'']/valueDate/@value)[1]','nvarchar(max)'),
           @WhenHandedOverValue = @WhenHandenOver.value('(//whenHandedOver/@value)[1]', 'nvarchar(max)');

    SET @AccepptDateValueOriginal = @AccepptDateValue;

    SET @AccepptDateValue = REPLACE(@AccepptDateValue, '-', '');
    SET @WhenHandedOverValue = REPLACE(@WhenHandedOverValue, '-', '');

    IF (@AccepptDateValue < @WhenHandedOverValue)
    BEGIN
        DECLARE @Anpassung XML;  
        SET @Anpassung =  (SELECT Blob FROM RW_EREZEPT_Abrechnung WHERE ERezeptID = @CurrentERezeptID);

        SET @Anpassung.modify('  
            replace value of (/*[local-name()="Bundle"]/*[local-name()="entry"]/*[local-name()="resource"]
            /*[local-name()="MedicationDispense"]/*[local-name()="whenHandedOver"]/@value)[1]  
            with sql:variable("@AccepptDateValueOriginal") 
        ');  

        UPDATE RW_EREZEPT_Abrechnung SET Blob = @Anpassung WHERE ERezeptID = @CurrentERezeptID;
		
		UPDATE RW_APOBASE_Rezept set cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID = @CurrentERezeptID;
		DELETE FROM RW_EREZEPT_RZErgebnis WHERE ERezeptID = @CurrentERezeptID;
    END

    FETCH NEXT FROM ERezeptID_Cursor INTO @CurrentERezeptID;
END

CLOSE ERezeptID_Cursor;
DEALLOCATE ERezeptID_Cursor;

--=======================================Rezeptur_Herstellungsuhrzeit=======================================--
/*
;WITH XMLNAMESPACES(DEFAULT 'http://hl7.org/fhir')
select distinct(r.ERezeptID), blob.value('(/Bundle/entry/resource/MedicationDispense/whenHandedOver/@value)[1]', 'nvarchar(30)') + 'T00:00:00Z' as NewTime 
into #rezeptur 
from RW_APOBASE_Rezept r
inner join RW_EREZEPT_RZErgebnis rz on r.ERezeptID = rz.ERezeptID
inner join RW_EREZEPT_Abrechnung a on r.ERezeptID = a.ERezeptID
where r.cKontrollStatus != 2 and rz.Kommentar like '%Der Herstellungszeitpunkt%ohne Zeitangabe ist ungültig%';

DECLARE @CurrentERezeptID NVARCHAR(25);

DECLARE ERezeptID_Cursor CURSOR FOR
SELECT ERezeptID FROM #rezeptur;

OPEN ERezeptID_Cursor;
FETCH NEXT FROM ERezeptID_Cursor INTO @CurrentERezeptID;

WHILE @@FETCH_STATUS = 0
BEGIN
	declare @rezeptur_Date nvarchar (30) = (select newtime from #rezeptur where ERezeptID = @CurrentERezeptID)
	UPDATE RW_EREZEPT_Abrechnung
*/--	SET Blob.modify('replace value of (/*[local-name()="Bundle"]/*[local-name()="entry"]/*[local-name()="resource"]/*[local-name()="MedicationDispense"]/*[local-name()="whenPrepared"]/@value)[1]  with sql:variable("@rezeptur_Date")') 
/*
	where ERezeptID = @CurrentERezeptID;

	update RW_APOBASE_Rezept set cKontrollStatus = 0, cFehlerTyp = 0 where ERezeptID = @CurrentERezeptID; 
	delete RW_EREZEPT_RZErgebnis where ERezeptID = @CurrentERezeptID; 
	
    FETCH NEXT FROM ERezeptID_Cursor INTO @CurrentERezeptID;
END

CLOSE ERezeptID_Cursor;
DEALLOCATE ERezeptID_Cursor;
DROP TABLE #rezeptur
*/