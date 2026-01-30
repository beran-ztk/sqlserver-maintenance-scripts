DECLARE @DateFrom INT = 20251000;
DECLARE @DateTo   INT = 20251100;

SELECT
    SUM(R.iAnzahl) AS Anzahl
FROM RW_APOBASE_Rezept AS R
INNER JOIN APO_ABDA_PAC_APO AS A
    ON R.diPzn = A.PZN
WHERE R.diDate BETWEEN @DateFrom AND @DateTo
  AND R.iRpNr = 0
  AND R.bStorno = 0
  AND R.cRpStatus IN (5, 13)
  AND R.bRezept = 0
  AND A.Rezeptpflicht IN (2, 3);
