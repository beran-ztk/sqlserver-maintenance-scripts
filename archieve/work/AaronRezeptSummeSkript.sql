select r1.diDate, r1.iRpNr, r1.iAnzahl, r1.diPzn, r1.diVk
into #1
from RW_APOBASE_Rezept r1
where r1.ERezeptID is null and r1.diDate between 20240801 and 20240925
order by r1.diDate, r1.iRpNr

select diDate, iRpNr, SUM(divk) as Summe
into #2
from RW_APOBASE_Rezept
where ERezeptID is null and diDate between 20240801 and 20240925
group by diDate, iRpNr
order by diDate, iRpNr

select #1.diDate, #1.iRpNr, #1.iAnzahl, #1.diPzn, #1.diVk, #2.Summe
from #1 
inner join #2 on #1.diDate = #2.diDate and #1.iRpNr = #2.iRpNr

drop table #1
drop table #2