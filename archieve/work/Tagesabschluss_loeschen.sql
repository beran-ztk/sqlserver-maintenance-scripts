Declare @D int = '20350520'; -- Hier das Datum eintragen was wieder geöffnet werden muss

declare @D2 int = (select top 1 diDate from RW_APOBASE_Tagesabschluss where bSchluss = 1 order by diDate desc); 
declare @D3 int = CONVERT(NVARCHAR(8), GETDATE(), 112)-14; -- Grenze liegt bei 14 Tage, wenn mehr geöffnet werden muss, dann einfach den wert auf 0 setzen select * from (select distinct top 1 diDate from RW_APOBASE_Tagesabschluss where bSchluss = 1 order by diDate desc)t order by didate desc select diwert from RW_APOBASE_Divers WHERE diIdentNr = 1662

while (LEN(@D) = 8) and (@D <= @D2) and (@D > @D3) 
Begin 
delete from RW_APOBASE_Tagesabschluss where diDate = @D2; 
UPDATE RW_APOBASE_Divers SET diWert = diWert-1 WHERE diIdentNr = 1662 
select * from (select distinct top 1 diDate from RW_APOBASE_Tagesabschluss where bSchluss = 1 order by diDate desc)t order by didate desc;
select diwert from RW_APOBASE_Divers WHERE diIdentNr = 1662 set @D2 = (select top 1 diDate from RW_APOBASE_Tagesabschluss where bSchluss = 1 order by diDate desc); 
END