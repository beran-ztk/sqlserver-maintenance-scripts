SELECT DISTINCT
    ERezeptID AS ID
INTO dbo.IDs
FROM dbo.ERezeptView
WHERE cKontrollStatus = 0
  AND cFehlerTyp      = 0
  AND bStorno         = 0
  and iRpNr           > 0
  AND diDate          < '20251001'
  AND CAST(Abrechnung AS nvarchar(max)) LIKE N'%|1.5%';

UPDATE a
SET a.Blob = REPLACE(CAST(a.Blob AS nvarchar(max)), N'|1.5', N'|1.4')
FROM dbo.RW_EREZEPT_Abrechnung a
INNER JOIN dbo.IDs i
    ON i.ID = a.ERezeptID;

UPDATE r
SET r.cKontrollStatus = 0,
    r.cFehlerTyp      = 0
FROM dbo.RW_APOBASE_Rezept r
INNER JOIN dbo.IDs i
    ON i.ID = r.ERezeptID;

DELETE rz
FROM dbo.RW_EREZEPT_RZErgebnis rz
INNER JOIN dbo.IDs i
    ON i.ID = rz.ERezeptID;

DROP TABLE dbo.IDs;