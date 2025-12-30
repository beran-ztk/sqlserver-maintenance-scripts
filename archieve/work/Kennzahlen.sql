declare @Ladenhueterpzn table (dipzn int)
insert into @Ladenhueterpzn (dipzn) select distinct(diPzn) from RW_APOBASE_Vorgaenge where didate >= CONVERT(NVARCHAR(8), DATEADD(MONTH, -12, GETDATE()), 112) 
declare @Ladenhueter table (dipzn int, bestand int)
insert into @Ladenhueter (dipzn, bestand) select distinct(diPzn), iBestand from RW_APOBASE_Lager where not diPzn in (select * from @Ladenhueterpzn) and iBestand > 0;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--‹bersicht Betriebliche Kennzahlen------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--D. Betriebliche Kennzahlen------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Lagerwert Ladenh¸ter
select sum(l.iBestand * a.diEk)as Lagerwert
from RW_APOBASE_Lager l
inner join UPD_ABDA_Artikel a on l.diPzn = a.diPzn
WHERE l.diPzn in (select dipzn from @Ladenhueter)

--Lagerh¸teranteil an Warenlager
DECLARE @num FLOAT;
set @num = 
(CAST((SELECT SUM(l.iBestand) 
       FROM RW_APOBASE_Lager l
       INNER JOIN UPD_ABDA_Artikel a ON l.diPzn = a.diPzn
       WHERE l.diPzn IN (SELECT dipzn FROM @Ladenhueter)) AS FLOAT))
	   /
(CAST((SELECT SUM(iBestand) FROM RW_APOBASE_Lager) AS FLOAT));
SELECT 'Lagerh¸teranteil Warenlager' as Hinweis,  LEFT(CONVERT(VARCHAR(10), @num), 4) + '%' as Anteil;




--E. HV-Leistung--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Kunde Pro Tag
SELECT(SELECT COUNT(DISTINCT strKundenName) FROM RW_APOBASE_Vorgaenge WHERE diDate LIKE '20240209%') +
(SELECT COUNT(DISTINCT ditime)FROM RW_APOBASE_Vorgaenge WHERE diDate LIKE '20240209%' AND strKundenName = 'nicht zugeordnet') AS TotalCount;


SELECT AVG(TotalCount) AS AverageTotalCount
FROM (
    SELECT diDate,(COUNT(DISTINCT strKundenName) + (SELECT COUNT(DISTINCT ditime) FROM RW_APOBASE_Vorgaenge AS v2
          WHERE v2.diDate = v1.diDate
            AND v2.strKundenName = 'nicht zugeordnet')
        ) AS TotalCount
    FROM RW_APOBASE_Vorgaenge AS v1
    GROUP BY diDate
) AS SubQuery;

--F. Vergleichswerte f¸r BWA--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Inventur nach AEK
Select SUM((l.iBestand * a.diEk)) as Lagerwert
from RW_APOBASE_Lager l
inner join UPD_ABDA_Artikel a on l.diPzn = a.diPzn
where l.iBestand > 0

--Inventur nach Zugangspreis
Select SUM((l.iBestand * a.divk)) as Lagerwert
from RW_APOBASE_Lager l
inner join UPD_ABDA_Artikel a on l.diPzn = a.diPzn
where l.iBestand > 0

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Prozess-Steuerung und Datenqualit‰t------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Artikel mit Bestand ¸ber 100 Packung
Select dipzn, iBestand from RW_APOBASE_Lager where iBestand >= 100 order by iBestand desc

--Artikel mit Bestand ¸ber 500 Packung
Select dipzn, iBestand from RW_APOBASE_Lager where iBestand >= 500 order by iBestand desc

--Artikel mit EK > 500Ä und Bestand
Select l.diPzn, a.diEk, l.iBestand
from RW_APOBASE_Lager l
inner join UPD_ABDA_Artikel a on l.diPzn = a.diPzn
WHERE diEk > 50000 and l.iBestand > 0
order by diEk desc

--Lagerpflegeprozesse--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Nichtlagerartikel mit Bestand

--Nichtlagerartikel mit negativem Bestand

--Lagerartikel ohne Bestand

--Artikel mit Lagerwert ¸ber 5000Ä (Einkaufspreis)
Select l.diPzn, (l.iBestand * a.diEk) as Lagerwert, l.iBestand, a.diEk
from RW_APOBASE_Lager l
inner join UPD_ABDA_Artikel a on l.diPzn = a.diPzn
WHERE (l.iBestand * a.diEk) > 5000
order by Lagerwert desc

--Bestellprozesse--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Artikel mit Reichweite ¸ber 6 Monate
SELECT diPzn, iBestand 
FROM RW_APOBASE_Lager
WHERE iBestand > 0 AND diLzBstDat <= CONVERT(NVARCHAR(8), DATEADD(MONTH, -6, GETDATE()), 112)

--Artikel mit Reichweite ¸ber 12 Monate
SELECT diPzn, iBestand 
FROM RW_APOBASE_Lager
WHERE iBestand > 0 AND diLzBstDat <= CONVERT(NVARCHAR(8), DATEADD(MONTH, -12, GETDATE()), 112)

--Ladenh¸ter kein Verkauf in 12 Monaten
select * from @Ladenhueter

--Preispflege--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Artikel mit Handelsspanne <= 0%
Select l.diPzn, a.diEk ,a.diVk, *
from RW_APOBASE_Lager l
inner join UPD_ABDA_Artikel a on l.diPzn = a.diPzn
inner join APO_ABDA_PAC_APO p on p.PZN = a.diPzn 
WHERE l.iBestand > 0 and p.Apopflicht = 2 and a.diEk >= a.diVk and a.diVk > 0;

--Lagerartikel ohne Verkaufspreis
Select l.diPzn, p.Apo_Ek
from RW_APOBASE_Lager l
inner join APO_ABDA_PAC_APO p on p.PZN = l.diPzn 
WHERE p.Apo_Ek = 0 and l.iBestand > 0 and p.Apopflicht = 2;

--Lagerartikel ohne Verkaufspreis
Select l.diPzn, a.divk
from RW_APOBASE_Lager l
inner join UPD_ABDA_Artikel a on l.diPzn = a.diPzn
inner join APO_ABDA_PAC_APO p on p.PZN = a.diPzn 
WHERE a.divk = 0 and l.iBestand > 0 and p.Apopflicht = 2;

--Kundenbezogene Daten--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Kundenkarten ohne vollst‰ndige Angaben
select strVorname,strName,'Vorname fehlt!' as Hinweis from RW_APOBASE_Kunde where strVorname is null
select strVorname,strName,'Straﬂe fehlt!' as Hinweis  from RW_APOBASE_Kunde where strStrasse is null
select strVorname,strName,'Versichertennummer fehlt!' as Hinweis  from RW_APOBASE_Kunde where strVersNr is null

--Kunden mit offenen Krediten

--Ehemalige Kunden mit offenen Krediten


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return
select top 100 * from APO_ABDA_Artikel where diPzn = 13889096
select top 100 divk,diEk,* from UPD_ABDA_Artikel
select top 100 * from APO_ABDA_PAC_APO
select * from RW_APOBASE_Lager
select * from RW_APOBASE_Bestellung 


select * from RW_APOBASE_Kundenrechnunghistorie   order by didat desc --8 storniert --6 bezahlt
select * from RW_APOBASE_Historie where diKdNr = 11749 order by didate desc
select * from RW_APOBASE_Vorgaenge where diKundenNr = 11749