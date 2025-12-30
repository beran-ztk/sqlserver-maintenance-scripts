SELECT DISTINCT(ERezeptID),v.didate, v.diVk, v.diPzn, v.strText, v.iVgNr, s.Charge as Charge, s.DT as cDatum, cast(null as nvarchar(max)) as Chargen
INTO #x 
FROM RW_APOBASE_Rezept r
 LEFT JOIN RW_APOBASE_Vorgaenge v ON r.iRpNr = v.iRpNr AND r.diDate = v.diDate
 LEFT JOIN APO_ABDA_Artikel a ON v.diPzn = a.diPzn
 LEFT JOIN RW_MODUL_SEC_VORGANG_SECURPHARM vs on v.iVgNr = vs.iVgNr AND v.diDate = vs.diDate AND v.diPzn = vs.diPzn
 LEFT JOIN RW_MODUL_SEC_Securpharm s ON vs.SecurpharmID = s.SecurPharmID
WHERE s.Charge IS NULL AND a.cRezeptpflicht = 2
  AND v.diPzn NOT IN ((9999175), (9999637), (9999005), (9999057), (2567024), (6461110), (2567001), (2567018), (8000001), (9999643), (2567024))
  AND r.ERezeptID IS NOT NULL AND r.bStorno = 0 AND r.iRpNr > 0 AND r.divk != r.diZahlbetrag AND NOT (cKontrollStatus = 2 AND cFehlerTyp = 5);

DECLARE @xID NVARCHAR(25);

DECLARE x_Cursor CURSOR FOR
	SELECT ERezeptID FROM #x;

OPEN x_Cursor;
FETCH NEXT FROM x_Cursor INTO @xID;

WHILE(@@FETCH_STATUS = 0)
BEGIN
	DECLARE @CHARGEN nvarchar(max) = '';
	DECLARE @pzn INT = (SELECT top 1 dipzn FROM #x WHERE ERezeptID = @xID);
	DECLARE @date INT = (SELECT top 1 didate FROM #x WHERE ERezeptID = @xID);
	DECLARE @charge nvarchar(50) = (SELECT TOP 1 s.Charge FROM RW_MODUL_SEC_Securpharm s WHERE s.Charge IS NOT NULL and GTIN like '%' + cast(@pzn as varchar(15)) + '%' AND format(DT, 'yyyyMMdd') BETWEEN (@date - 5) AND (@date +5) ORDER BY s.DT DESC);
	DECLARE @datum nvarchar(50) = (SELECT TOP 1 s.DT FROM RW_MODUL_SEC_Securpharm s  WHERE  s.Charge IS NOT NULL and GTIN like '%' + cast(@pzn as varchar(15)) + '%' AND format(DT, 'yyyyMMdd') BETWEEN (@date - 5) AND (@date+5) ORDER BY s.DT DESC);

		select distinct(charge),dt INTO #c from RW_MODUL_SEC_Securpharm where GTIN like '%' + cast(@pzn as varchar(15)) + '%' and strmes like '%verify%' ORDER BY DT
		DECLARE @cID NVARCHAR(25);

DECLARE @cCharge NVARCHAR(50);
DECLARE @cDT DATETIME;

DECLARE c_Cursor CURSOR FOR
    SELECT Charge, DT FROM #c ORDER BY DT desc;

OPEN c_Cursor;
FETCH NEXT FROM c_Cursor INTO @cCharge, @cDT;
WHILE(@@FETCH_STATUS = 0)
BEGIN
    SET @CHARGEN += @cCharge + ' - ' + FORMAT(@cDT, 'dd-MM-yyyy') + ' /// ';
    FETCH NEXT FROM c_Cursor INTO @cCharge, @cDT;
END
CLOSE c_Cursor;
DEALLOCATE c_Cursor;


	update #x set Chargen = @chargen WHERE ERezeptID = @xID;
	update #x set Charge = @charge, cDatum = @datum WHERE ERezeptID = @xID;
	FETCH NEXT FROM x_Cursor INTO @xID;
	drop table #c
END
CLOSE x_Cursor;
DEALLOCATE x_Cursor;

select * from #x order by diVk desc

drop table #x

