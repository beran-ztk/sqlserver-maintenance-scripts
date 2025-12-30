select * from RW_APOBASE_Historie where iAnzahl = 2147483647 or iAnzahl < -100 or diVk = 2147483647 or diVk < -100000
update RW_APOBASE_Historie set iAnzahl = 1 where iAnzahl = 2147483647 or iAnzahl < -100
update RW_APOBASE_Historie set diVk = 1 where diVk = 2147483647 or diVk < -100000

select * from RW_APOBASE_Vorgaenge where iAnzahl = 2147483647 or iAnzahl < -100 or diVk = 2147483647 or diVk < -100000
update RW_APOBASE_Vorgaenge set iAnzahl = 1 where iAnzahl = 2147483647 or iAnzahl < -100
update RW_APOBASE_Vorgaenge set diVk = 1 where diVk = 2147483647 or diVk < -100000

select * from RW_APOBASE_Rezept where iAnzahl = 2147483647 or iAnzahl < -100 or diVk = 2147483647 or diVk < -100000
update RW_APOBASE_Rezept set iAnzahl = 1 where iAnzahl = 2147483647 or iAnzahl < -100
update RW_APOBASE_Rezept set diVk = 1 where diVk = 2147483647 or diVk < -100000