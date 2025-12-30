

	DECLARE @E NVARCHAR (25) = '100.000.000.000.000.00', @CH NVARCHAR (25) = '0';

    DECLARE @Abrechnung XML, @AbrechnungValue NVARCHAR(25); 
	
    SELECT @Abrechnung = Blob FROM RW_EREZEPT_Abrechnung WHERE ERezeptID = @E;

    ;WITH XMLNAMESPACES(DEFAULT 'http://hl7.org/fhir')
    SELECT @AbrechnungValue = @Abrechnung.value('(//extension[@url=''http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Chargenbezeichnung'']/valueString/@value)[1]','nvarchar(max)');
	
	select @Abrechnung
		

		SET @Abrechnung.modify('insert <Material>Aluminium</Material>
		into (/*[local-name()="Bundle"]/*[local-name()="entry"]/*[local-name()="resource"]
            /*[local-name()="MedicationDispense"]/*[local-name()="authorizingPrescription"]/*[local-name()="identifier"]
			/*[local-name()="value"]/@value)[1] 
		'); 
		
		 UPDATE RW_EREZEPT_Abrechnung SET Blob = @Abrechnung WHERE ERezeptID = @E;

		 select * from RW_EREZEPT_Abrechnung where ERezeptID = '100.000.000.000.000.00';

		  <extension url="http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Chargenbezeichnung">
            <valueString value="A326632" />
          </extension>

        SET @Abrechnung.modify('  
            replace value of (/*[local-name()="Bundle"]/*[local-name()="identifier"]/*[local-name()="value"]/@value)[1]  
            with sql:variable("@E") 
        ');  
  
		 SET @Abrechnung.modify('  
            replace value of (/*[local-name()="Bundle"]/*[local-name()="entry"]/*[local-name()="resource"]
            /*[local-name()="MedicationDispense"]/*[local-name()="authorizingPrescription"]/*[local-name()="identifier"]
			/*[local-name()="value"]/@value)[1]  
            with sql:variable("@E") 
        ');    

        UPDATE RW_EREZEPT_Abrechnung SET Blob = @Abrechnung WHERE ERezeptID = @E;
		
		UPDATE RW_APOBASE_Rezept set cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID = @E;
		DELETE FROM RW_EREZEPT_RZErgebnis WHERE ERezeptID = @E;
    


	USE apobase;  
GO  
CREATE TABLE T (i INT, x XML);  
GO  
INSERT INTO T VALUES(1,'<Root>  
    <ProductDescription ProductID="1" ProductName="Road Bike">  
        <Features>  
            <Warranty>1 year parts and labor</Warranty>  
            <Maintenance>3 year parts and labor extended maintenance is available</Maintenance>  
        </Features>  
    </ProductDescription>  
</Root>');  
GO  
-- insert a new element  
UPDATE T  
SET x.modify('insert <Material>Aluminium</Material> as first  
  into   (/Root/ProductDescription/Features)[1]  
');  
GO
select * from t