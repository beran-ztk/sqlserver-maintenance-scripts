	SELECT DISTINCT 
			r.ERezeptID, 
			SUBSTRING(CONVERT(VARCHAR(10), r.didate), 7, 2) + '/' + SUBSTRING(CONVERT(VARCHAR(10), r.didate), 5, 2) + '/' + LEFT(CONVERT(VARCHAR(10), r.didate), 4) AS Datum,
				CASE 
					WHEN LEN(CONVERT(VARCHAR(20), r.ditime)) = 8 THEN '0' + LEFT(CONVERT(VARCHAR(20), r.ditime), 1) + ':' + SUBSTRING(RIGHT(CONVERT(VARCHAR(20), r.ditime), 7), 1, 2)
					ELSE LEFT(CONVERT(VARCHAR(20), r.ditime), LEN(CONVERT(VARCHAR(20), r.ditime)) - 7) + ':' + SUBSTRING(RIGHT(CONVERT(VARCHAR(20), r.ditime), 7), 1, 2)
				END AS Uhrzeit,
			r.strText,
			'Charge fehlt!!' AS Charge,
			r.didate AS Reihenfolge
			
	FROM 
			RW_APOBASE_Rezept r 
			LEFT JOIN RW_APOBASE_Vorgaenge v ON r.didate = v.didate AND r.iRpNr = v.iRpNr and r.diPzn = v.diPzn
			LEFT JOIN RW_MODUL_SEC_VORGANG_SECURPHARM s ON v.didate = s.diDate and v.iVgNr = s.iVgNr and v.diPzn = s.diPzn
			LEFT JOIN RW_MODUL_SEC_Securpharm sec ON sec.SecurPharmID = s.SecurpharmID
			
	WHERE 
				r.iRpNr >= 1
			AND r.bStorno = 0 
			AND r.cFehlerTyp != 5 
			AND v.diLfdNr IS NOT NULL
			AND	r.ERezeptID IS NOT NULL 
			AND NOT r.diPzn IN ('6461110', '2567024') 
			AND (s.SecurpharmID IS NULL OR sec.Charge IN (NULL, '0', 'STEPPEN'))

				
	ORDER BY 
			Reihenfolge;