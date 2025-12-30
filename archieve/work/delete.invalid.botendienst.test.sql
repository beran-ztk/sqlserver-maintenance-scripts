BEGIN TRAN
SELECT * FROM ApobaseMesse.dbo.MODUL_Botendienst ORDER BY diDate DESC;
DELETE ApobaseMesse.dbo.MODUL_Botendienst
WHERE CONVERT(date, CONVERT(varchar(8), diDate)) < DATEADD(DAY, -41, CAST(GETDATE() AS date));
SELECT * FROM ApobaseMesse.dbo.MODUL_Botendienst ORDER BY diDate DESC;
ROLLBACK TRAN