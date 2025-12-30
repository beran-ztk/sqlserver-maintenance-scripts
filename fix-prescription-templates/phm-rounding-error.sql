DECLARE abrechnung_cursor CURSOR FOR 
SELECT EReZeptID,Abrechnung FROM ERezeptView WHERE ERezeptID LIKE '980.%' AND diDate > 20251100
Open abrechnung_cursor;

DECLARE @id varchar(50);
DECLARE @abrechnung XML;
DECLARE @HIMI bigint;
DECLARE @FAKTOR int;
DECLARE @PREIS DECIMAL(10,4);
DECLARE @EINZELPREIS DECIMAL(10,4);
DECLARE @FORMAT varchar(10);

FETCH NEXT FROM abrechnung_cursor INTO @id, @abrechnung;

WHILE @@FETCH_STATUS = 0  
BEGIN
WITH XMLNAMESPACES 
(
DEFAULT 'http://hl7.org/fhir' 
)
SELECT  @HIMI = @abrechnung.value('(//chargeItemCodeableConcept/coding/code/@value)[1]', 'varchar(max)');
WITH XMLNAMESPACES 
(
DEFAULT 'http://hl7.org/fhir' 
)
SELECT @FAKTOR = @abrechnung.value('(//priceComponent/factor/@value)[1]', 'int');
WITH XMLNAMESPACES 
(
DEFAULT 'http://hl7.org/fhir' 
)
SELECT @PREIS = @abrechnung.value('(//priceComponent/amount/value/@value)[1]', 'decimal(10,4)');

IF (@HIMI = 18774742)
BEGIN
	SET @abrechnung.modify('declare namespace ns="http://hl7.org/fhir"; 
	replace value of(//ns:lineItem/ns:chargeItemCodeableConcept/ns:coding/ns:system/@value)[1] with "http://fhir.de/sid/gkv/hmnr"');

	IF (@FAKTOR > 1)
	BEGIN
		SET @EINZELPREIS = @PREIS / @FAKTOR;
		SELECT @EINZELPREIS
		IF (ABS(@EINZELPREIS - 0.0714) < 0.01)
		BEGIN
			SET @HIMI = 5499010001;
			SET @PREIS = ROUND(0.0714 * @FAKTOR,2);
		END
		ELSE IF ( ABS(@EINZELPREIS - 0.1071) < 0.1)
		BEGIN
			SET @HIMI = 5499011001;
			SET @PREIS = ROUND(0.1071 * @FAKTOR,2);
		END
		ELSE IF (ABS(@EINZELPREIS - 0.1666) < 0.01)
		BEGIN
			SET @HIMI = 5499012001;
			SET @PREIS = ROUND(0.1666 * @FAKTOR,2);
		END
		ELSE IF (ABS(@EINZELPREIS - 0.1547) < 0.01)
		BEGIN
			SET @HIMI = 5499013001;
			SET @PREIS = ROUND(0.1547 * @FAKTOR,2);
		END
		ELSE IF (ABS(@EINZELPREIS - 24.990) < 0.01)
		BEGIN
			SET @HIMI = 5499013002;
			SET @PREIS = ROUND(24.990 * @FAKTOR,2);
		END
		ELSE IF (ABS(@EINZELPREIS - 0.9520) < 0.01)
		BEGIN
			SET @HIMI = 5499015001;
			SET @PREIS = ROUND(0.9520 * @FAKTOR,2);
		END
		ELSE IF (ABS(@EINZELPREIS - 1.6660) < 0.01)
		BEGIN
			SET @HIMI = 5499020001;
			SET @PREIS = ROUND(1.6660 * @FAKTOR,2);
		END
		ELSE IF (ABS(@EINZELPREIS - 1.5470) < 0.01)
		BEGIN
			SET @HIMI = 5499020002;
			SET @PREIS = ROUND(1.5470 * @FAKTOR,2);			
		END
		ELSE IF (ABS(@EINZELPREIS - 0.2142) < 0.01)
		BEGIN
			SET @HIMI = 5499020014;
			SET @PREIS = ROUND(0.2142 * @FAKTOR,2);
		END
		ELSE IF (ABS(@EINZELPREIS - 0.2023) < 0.01)
		BEGIN
			SET @HIMI = 5499020015;
			SET @PREIS = ROUND(0.2023 * @FAKTOR,2);
		END
		ELSE IF (ABS(@EINZELPREIS - 0.5236) < 0.01)
		BEGIN
			SET @HIMI = 5445010001;
			SET @PREIS = ROUND(0.5236 * @FAKTOR,2);
		END
		ELSE IF (ABS(@EINZELPREIS - 26.180) < 0.01)
		BEGIN
			SET @HIMI = 5140014;
			SET @PREIS = ROUND(26.180 * @FAKTOR,2);
		END
		ELSE
		BEGIN
			PRINT 'FEHLER' + @id
		END

		SET @FORMAT = LTRIM(STR(@PREIS,10,2));

		SET @abrechnung.modify('declare namespace ns="http://hl7.org/fhir"; 
		replace value of(//ns:lineItem/ns:chargeItemCodeableConcept/ns:coding/ns:code/@value)[1] with sql:variable("@HIMI")');

		SET @abrechnung.modify('declare namespace ns="http://hl7.org/fhir"; 
		replace value of(//ns:lineItem/ns:priceComponent/ns:amount/ns:value/@value)[1] with sql:variable("@FORMAT")');
	END
END

	

	--SELECT @abrechnung
	--SELECT @id, @abrechnung
	UPDATE RW_EREZEPT_Abrechnung SET Blob = @abrechnung WHERE ERezeptID = @id;
	-- //lineitem/priceComponent/amount/@value = PRICE

FETCH NEXT FROM abrechnung_cursor INTO @id, @abrechnung;  
END   
CLOSE abrechnung_cursor;  
DEALLOCATE abrechnung_cursor;  
GO  

UPDATE RW_APOBASE_Rezept SET cKontrollstatus = 0, cFehlertyp = 0 WHERE ERezeptID LIKE '980.%' AND cKontrollstatus = 4
