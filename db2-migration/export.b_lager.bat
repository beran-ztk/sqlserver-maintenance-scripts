db2 "export to C:\Temp\Export\B_LAGER.csv of del modified by coldel; 
        decpt=. timestampformat=\"YYYY-MM-DD HH:MM:SS\"
     select
       ..., 
       varchar(decimal(GES_D_BSTD_MNG,18,0)) as GES_D_BSTD_MNG,
       ...
     from <SCHEMA>.B_LAGER"