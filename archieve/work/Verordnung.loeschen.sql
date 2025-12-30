WITH XMLNAMESPACES(DEFAULT 'http://hl7.org/fhir')
SELECT a.ERezeptID, (a.blob.value('(//extension[@url=''https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_AcceptDate'']/valueDate/@value)[1]', 'nvarchar(max)')) AS x
FROM RW_EREZEPT_Verordnung a
	INNER JOIN RW_EREZEPT_Verlorene v ON a.ERezeptID = v.ERezeptID
WHERE (REPLACE(a.blob.value('(//extension[@url=''https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_AcceptDate'']/valueDate/@value)[1]', 'nvarchar(max)'), '-', '')) < DATEADD(WEEK, -8, GETDATE())
ORDER BY x desc

WITH XMLNAMESPACES(DEFAULT 'http://hl7.org/fhir')
DELETE RW_EREZEPT_Verordnung WHERE ERezeptID IN
(
SELECT a.ERezeptID
FROM RW_EREZEPT_Verordnung a
	INNER JOIN RW_EREZEPT_Verlorene v ON a.ERezeptID = v.ERezeptID
WHERE (REPLACE(a.blob.value('(//extension[@url=''https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_AcceptDate'']/valueDate/@value)[1]', 'nvarchar(max)'), '-', '')) < DATEADD(WEEK, -8, GETDATE())
);