DELETE MODUL_Botendienst
WHERE CONVERT(date, CONVERT(varchar(8), diDate)) < DATEADD(DAY, -41, CAST(GETDATE() AS date));