DECLARE @X XML;
DECLARE @id varchar(50);
DECLARE @Verordnung varchar(MAX);

DECLARE id_cursor CURSOR FOR
SELECT ERezeptID, CAST(Verordnung AS varchar(MAX)) FROM ERezeptView WHERE ERezeptID LIKE '980.%' AND diDate > 20251100 AND CAST(Verordnung as varchar(max)) LIKE 'MIA%' AND cKontrollStatus IN (0,4)
OPEN id_cursor;  
  
FETCH NEXT FROM id_cursor INTO @id, @Verordnung;  

WHILE @@FETCH_STATUS = 0  
BEGIN  

SELECT @X = 
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(CAST(SUBSTRING(CAST('' AS XML).value('xs:base64Binary(sql:variable("@Verordnung"))', 'VARBINARY(MAX)'),
CHARINDEX('<Bundle',CAST('' AS XML).value('xs:base64Binary(sql:variable("@Verordnung"))', 'VARBINARY(MAX)'),0),
CHARINDEX('</Bundle>',CAST('' AS XML).value('xs:base64Binary(sql:variable("@Verordnung"))', 'VARBINARY(MAX)'),0)+9-CHARINDEX('<Bundle',CAST('' AS XML).value('xs:base64Binary(sql:variable("@Verordnung"))', 'VARBINARY(MAX)'),0)) AS varchar(MAX)),
'<system value="http://unitsofmeasure.org"/><code value="{Package}"/>',
'<unit value="Packung"/>'),
'</form></Medication>',
'</form><amount><numerator><extension url="https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_PackagingSize"><valueString value="1"/></extension><unit value="St"/></numerator><denominator><value value="1"/></denominator></amount><ingredient><itemCodeableConcept><text value="---"/></itemCodeableConcept><strength><numerator><value value="1"/><unit value="St"/></numerator><denominator><value value="1"/><unit value="St"/></denominator></strength></ingredient></Medication>'
),
'<version value="http://snomed.info/sct/900000000000207008/version/20220331"/>',
'<version value="http://snomed.info/sct/11000274103/version/20240515"/>'
),
'<extension url="http://fhir.de/StructureDefinition/normgroesse"><valueCode value="KA"/></extension>',
''
),
'<system value="http://fhir.de/CodeSystem/identifier-type-de-basis"/><code value="PKV"/>',
'<system value="http://fhir.de/CodeSystem/identifier-type-de-basis"/><code value="KVZ10"/>'
),
'KBV_PR_FOR_Patient|1.1.0',
'KBV_PR_FOR_Patient|1.2'
),
'KBV_PR_FOR_Organization|1.1.0',
'KBV_PR_FOR_Organization|1.2'
),
'KBV_PR_FOR_Coverage|1.1.0',
'KBV_PR_FOR_Coverage|1.2'
),
'KBV_PR_FOR_Practitioner|1.1.0',
'KBV_PR_FOR_Practitioner|1.2'
),
'|1.1.0',
'|1.3'
),
'<extension url="https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_BVG">',
'<extension url="https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_SER">'
),
'http://fhir.de/sid/pkv/kvid-10',
'http://fhir.de/sid/gkv/kvid-10'
)


SELECT @X;
UPDATE RW_EREZEPT_Verordnung SET Blob = @X WHERE ERezeptID = @id;
UPDATE ERezeptView SET cKontrollStatus = 0, cFehlertyp = 0 WHERE ERezeptID = @id;
FETCH NEXT FROM id_cursor INTO @id, @Verordnung;  
END  
  
CLOSE id_cursor;  
DEALLOCATE id_cursor;  
GO  

