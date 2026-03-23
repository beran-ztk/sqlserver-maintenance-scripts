WITH XMLNAMESPACES(DEFAULT 'http://hl7.org/fhir')
SELECT a.ERezeptID, (a.blob.value('(//extension[@url=''https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_AcceptDate'']/valueDate/@value)[1]', 'nvarchar(max)')) AS x
FROM RW_EREZEPT_Verordnung a
	INNER JOIN RW_EREZEPT_Verlorene v ON a.ERezeptID = v.ERezeptID
WHERE (REPLACE(a.blob.value('(//extension[@url=''https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_AcceptDate'']/valueDate/@value)[1]', 'nvarchar(max)'), '-', '')) 
		< DATEADD(DAY, -100, GETDATE()) -- Select, wo AcceptDate älter als 100 Tage
ORDER BY x desc