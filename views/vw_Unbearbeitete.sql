-- 1 = gültig // 2 = ungültig
;WITH XMLNAMESPACES(DEFAULT 'http://hl7.org/fhir')
SELECT ERezeptID,
format(dateadd(day, 0, LEFT((REPLACE(blob.value('(/Bundle/entry/resource/Task/authoredOn/@value)[1]', 'varchar(50)'), '-', '')), 8)), 'yyyyMMdd') AS Authored,
format(dateadd(day, 100, LEFT((REPLACE(blob.value('(/Bundle/entry/resource/Task/authoredOn/@value)[1]', 'varchar(50)'), '-', '')), 8)), 'yyyyMMdd') AS Valid,
CASE 
	WHEN
		format(dateadd(day, 100, LEFT((REPLACE(blob.value('(/Bundle/entry/resource/Task/authoredOn/@value)[1]', 'varchar(50)'), '-', '')), 8)), 'yyyyMMdd') > format(GETDATE(), 'yyyyMMdd') THEN 1
	ELSE 2
	end as status
INTO #temp
FROM RW_EREZEPT_Verordnung
WHERE ERezeptID IN (select ERezeptID from RW_APOBASE_NachlieferungInfo where ERezeptID is not null)
   OR ERezeptID IN (select TOP 1000 ERezeptID from RW_EREZEPT_Verlorene where ERezeptID LIKE  '160.%' AND NOT ERezeptID in (select erezeptid from RW_EREZEPT_Dispense));

