
DECLARE @IDE TABLE (ERezeptID NVARCHAR(25));

INSERT INTO @IDE (ERezeptID)
SELECT ERezeptID 
FROM RW_EREZEPT_RZErgebnis 
WHERE Kommentar LIKE '%E-Rezept-ID%eindeutig%'
AND NOT ERezeptID IN (SELECT ERezeptID FROM RW_APOBASE_Rezept WHERE cKontrollStatus = 2 and ERezeptID IS NOT NULL);

DECLARE @IDCurrentERezept NVARCHAR(25);

DECLARE ID_Cursor CURSOR FOR
SELECT ERezeptID FROM @IDE;

OPEN ID_Cursor;
FETCH NEXT FROM ID_Cursor INTO @IDCurrentERezept;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @ERP NVARCHAR(25),
			@PrescriptionID XML,
            @PrescriptionIdValue NVARCHAR(25); 

    SELECT @PrescriptionID = Blob FROM RW_EREZEPT_Abrechnung WHERE ERezeptID = @IDCurrentERezept;

    ;WITH XMLNAMESPACES(DEFAULT 'http://hl7.org/fhir')
    SELECT @PrescriptionIdValue = @PrescriptionID.value('(//value/@value)[1]', 'nvarchar(max)');

    SET @ERP = REPLACE(@IDCurrentERezept, '-', '');
	SET @PrescriptionIdValue = REPLACE(@PrescriptionIdValue, '-', '');

    IF (@ERP != @PrescriptionIdValue)
    BEGIN
        DECLARE @Fix XML;  
        SET @Fix =  (SELECT Blob FROM RW_EREZEPT_Abrechnung WHERE ERezeptID = @IDCurrentERezept);

        SET @Fix.modify('  
            replace value of (/*[local-name()="Bundle"]/*[local-name()="identifier"]/*[local-name()="value"]/@value)[1]  
            with sql:variable("@IDCurrentERezept") 
        ');  
  
		 SET @Fix.modify('  
            replace value of (/*[local-name()="Bundle"]/*[local-name()="entry"]/*[local-name()="resource"]
            /*[local-name()="MedicationDispense"]/*[local-name()="authorizingPrescription"]/*[local-name()="identifier"]
			/*[local-name()="value"]/@value)[1]  
            with sql:variable("@IDCurrentERezept") 
        ');    

        UPDATE RW_EREZEPT_Abrechnung SET Blob = @Fix WHERE ERezeptID = @IDCurrentERezept;
		
		UPDATE RW_APOBASE_Rezept set cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID = @IDCurrentERezept;
		DELETE FROM RW_EREZEPT_RZErgebnis WHERE ERezeptID = @IDCurrentERezept;
    END

    FETCH NEXT FROM ID_Cursor INTO @IDCurrentERezept;
END

CLOSE ID_Cursor;
DEALLOCATE ID_Cursor;


