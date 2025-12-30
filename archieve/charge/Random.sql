Select distinct(r.erezeptid), s.Charge, r.didate,r.ditime, r.diPzn
from RW_APOBASE_Rezept r
left join RW_APOBASE_Vorgaenge v on r.diDate = v.diDate and r.iRpNr = v.iRpNr
left join RW_MODUL_SEC_VORGANG_SECURPHARM vs on vs.iVgNr = v.iVgNr and vs.diDate = v.diDate 
left join RW_MODUL_SEC_Securpharm s on vs.SecurpharmID = s.SecurPharmID
where not (r.cKontrollStatus = 2 and r.cFehlerTyp = 5)
 and r.ERezeptID is not null
 and r.cRpStatus != 5
 and r.bStorno = 0
 and s.charge is null
 and r.diPzn != 9999011
 and r.ERezeptID in
 (select r.erezeptid from RW_APOBASE_Rezept r
 inner join APO_ABDA_Artikel a on r.diPzn = a.diPzn
 where r.ERezeptID is not null 
 and a.cRezeptpflicht = 2)

 and not r.ERezeptID in  (select r.erezeptid from RW_APOBASE_Rezept r
 inner join APO_ABDA_Artikel a on r.diPzn = a.diPzn
 where r.ERezeptID is not null 
 and a.strDarKey in ('TTR','VER'));


 -- select Produktgruppe,* from APO_ABDADB_Fam_db;


*--- WICHTIGGGGGGGGGGGGGGGGG
select ERezeptID, diDate ,diTime
		into #temp
	from ERezeptView 
	where Dispense is null 
		and bStorno = 0 
		and iRpNr > 0
			
			select * from #temp

			drop table #temp