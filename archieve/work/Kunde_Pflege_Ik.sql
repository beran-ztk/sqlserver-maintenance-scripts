ALTER TABLE rw_apobase_kunde
ADD pflegekasseIK INT;
GO
UPDATE kunde
SET kunde.pflegekasseIK = ik.Ik
FROM RW_APOBASE_Kunde kunde
INNER JOIN APO_PLUSV_Ikz ik ON right(kunde.diKKNr, 7) = right(ik.IK, 7)
WHERE kunde.diKKNr IS NOT NULL
  AND (left(kunde.diKKNr, 2) = 10 AND left(ik.Ik, 2) = 18);
GO