select top 10 * from [STG_E_GP] where GP_NAME like '%DENTINOX GESELLSCHAFT FÜR PHARMAZEUTISCH%'
select top 100 * from [STG_E_GP_KD_SPEZ]
select * from [STG_E_GP_KOTR_SPEZ]
select * from RW_APOBASE_Kunde

--return
DBCC TRACEON(460, -1);
DELETE [STG_E_STAMMDATEN] where gp_nr = 92377 AND KD_NR = 10493
DELETE [STG_E_STAMMDATEN] where gp_nr = 45592429 AND KD_NR = 2872
DELETE [STG_E_STAMMDATEN] where gp_nr = 45593421 AND KD_NR = 918
DELETE [STG_E_STAMMDATEN] where gp_nr = 45593670 AND KD_NR = 6305

--Kürzung Feldinhalte (Abschneiden von "zu viel" Infos)
 UPDATE [STG_E_GP] SET GP_NAME = LEFT(GP_NAME, 40);
-- UPDATE kundenexport SET Vorname = LEFT(Vorname, 40);
 UPDATE [STG_E_GP] SET GP_STR = LEFT(GP_STR, 40);
-- UPDATE kundenexport SET Wohnort = LEFT(Wohnort, 40);
 UPDATE [STG_E_GP] SET GP_TELEFON = LEFT(GP_TELEFON, 30);
-- UPDATE kundenexport SET Mobil_Nr = LEFT(Mobil_Nr, 30);
-- UPDATE kundenexport SET Fax = LEFT(Fax, 30);
-- UPDATE kundenexport SET E_Mail = LEFT(E_Mail, 50);
-- UPDATE kundenexport SET Kundenkarten_Nummern = LEFT(Kundenkarten_Nummern, 9);

--Anpassung Feldbreiten 
-- ALTER TABLE kundenexport ALTER COLUMN Name_Bezeichnung nvarchar(40)
-- ALTER TABLE kundenexport ALTER COLUMN Vorname nvarchar(40)
-- ALTER TABLE kundenexport ALTER COLUMN Straße nvarchar(40)
-- ALTER TABLE kundenexport ALTER COLUMN Wohnort nvarchar(40)
-- ALTER TABLE kundenexport ALTER COLUMN Telefon nvarchar(30)
-- ALTER TABLE kundenexport ALTER COLUMN Mobil_Nr nvarchar(30)
-- ALTER TABLE kundenexport ALTER COLUMN Fax nvarchar(30)
-- ALTER TABLE kundenexport ALTER COLUMN E_Mail nvarchar(50)
-- ALTER TABLE kundenexport ALTER COLUMN Kundenkarten_Nummern nvarchar(9)

--Anpassung RW_APOBASE_Kunde für Ident
--ALTER TABLE RW_APOBASE_Kunde ALTER COLUMN strIdent nvarchar(40)

BEGIN TRY

BEGIN TRANSACTION InsertKunde

--Korrekturen blöder Daten:
--UPDATE kundenexport SET PLZ = '97422' WHERE PLZ = '9742X'

SET IDENTITY_INSERT RW_APOBASE_Kunde ON

INSERT INTO RW_APOBASE_Kunde 
(
	diKdNrAuto, 
	strName, 
	strVorname, 
	strStrasse, 
	diPlz, 
	strPlz,
	strOrt,
	diGebDat, 
	strAnrede, 
	diBefrBisDat, 
	diGltBisDat, bytGeschlecht, diKKNr, iKuKaNr, strTelNrP, strFaxNr, strIdent, strVersNr
)
SELECT
DISTINCT
    TRY_CAST(q.GP_NR AS INT),
    q.GP_NAME,
	q.GP_VNAME,
	q.GP_STR,
	TRY_CAST(q.GP_PLZ AS INT),
	q.GP_PLZ,
	q.GP_ORT,
    q.GP_GEB_DATUM,
	q.GP_ANR,
    s.KD_ZUZ_BIS_DATUM,
	s.KD_ZUZ_BIS_DATUM,
	CASE 
        WHEN q.GP_ANR = 'HERR' THEN 1
        WHEN q.GP_ANR = 'FRAU' THEN 2
        ELSE NULL
    END AS byGeschlecht,
	k.GP_KOTR_KIK_NR,
	TRY_CAST(d.KD_NR AS INT),
	q.GP_TELEFON,
	q.GP_TELEX,
	q.GP_TIT,
	s.VERS_NR
FROM [STG_E_GP] q
LEFT JOIN [STG_E_GP_KD_SPEZ] s on q.GP_NR = s.GP_NR
left join [STG_E_GP_KOTR_SPEZ] k on q.GP_NR = k.GP_NR
left join [STG_E_STAMMDATEN] d on q.gp_nr = d.GP_NR
WHERE GP_KD_FLG = 'J'
and len(gp_plz) < 10;

--Nachkorrekturen
update RW_APOBASE_Kunde set diGebDat = null where diGebDat = 99991231
-- UPDATE RW_APOBASE_Kunde SET diKKNr = 999999994 WHERE diKKNr = 100000000
-- UPDATE RW_APOBASE_Kunde SET cStatus = ASCII('N')
-- UPDATE RW_APOBASE_Kunde SET cStatus = ASCII('B') WHERE diBefrBisDat >= 20250000

-- UPDATE RW_APOBASE_Kunde SET strPlz = 'A 8334' WHERE diKdNrAuto = 11061
-- UPDATE RW_APOBASE_Kunde SET strPlz = 'A 1050' WHERE diKdNrAuto = 18053
-- UPDATE RW_APOBASE_Kunde SET strPlz = 'A 5113' WHERE diKdNrAuto = 15998
-- UPDATE RW_APOBASE_Kunde SET strPlz = 'PL 43-600' WHERE diKdNrAuto = 18171
-- UPDATE RW_APOBASE_Kunde SET strPlz = 'PL 65-735' WHERE diKdNrAuto = 18929

EXEC sp_Wartung_Create_Kunde_Suchname

SET IDENTITY_INSERT RW_APOBASE_Kunde OFF

COMMIT
END TRY
BEGIN CATCH
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
	SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
	RAISERROR(@ErrMsg, @ErrSeverity, 1)
	ROLLBACK TRANSACTION InsertKunde
	PRINT 'ROLLBACK erfolgt wegen Fehlern'
END CATCH