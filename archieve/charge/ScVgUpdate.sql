UPDATE s SET s.iVgNr = COALESCE(s.iVgNr, v.iVgNr), s.diDate = COALESCE(s.diDate, v.diDate), s.diPzn = COALESCE(s.diPzn, v.diPzn)
FROM RW_MODUL_SEC_VORGANG_SECURPHARM s
LEFT JOIN RW_APOBASE_Vorgaenge v
ON s.diLfdNr = v.diLfdNr

