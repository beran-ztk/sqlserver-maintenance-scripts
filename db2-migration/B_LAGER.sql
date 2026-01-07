USE [ProkasStaging]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE IF EXISTS B_LAGER;
DROP TABLE IF EXISTS dbo.B_LAGER_STG;

CREATE TABLE dbo.B_LAGER_STG
(
    ART_TYP_NR nvarchar(50) NULL,
    LORT_NR nvarchar(50) NULL,
    LORT_KURZ nvarchar(50) NULL,
    GES_BSTD_MNG nvarchar(50) NULL,
    GES_D_BSTD_MNG nvarchar(50) NULL,
    LAG_FLG nvarchar(10) NULL,
    LAG_ENTST_DAT nvarchar(50) NULL,
    GES_MBSTD_MNG nvarchar(50) NULL,
    GES_EBSTD_MNG nvarchar(50) NULL,
    GES_AMO nvarchar(50) NULL,
    GES_AMO_DAT nvarchar(50) NULL,
    GES_AMO_ZEIT nvarchar(50) NULL,
    GES_TREND nvarchar(50) NULL,
    UEB_FLG nvarchar(10) NULL,
    UEB_LORT_NR nvarchar(50) NULL,
    UEB_LORT_KURZ nvarchar(50) NULL,
    REG_BSTD_MNG nvarchar(50) NULL,
    REG_MBSTD_MNG nvarchar(50) NULL,
    REG_EBSTD_MNG nvarchar(50) NULL,
    REG_KAP_MNG nvarchar(50) NULL,
    REG_AMO nvarchar(50) NULL,
    REG_AMO_DAT nvarchar(50) NULL,
    REG_AMO_ZEIT nvarchar(50) NULL,
    REG_TREND nvarchar(50) NULL,
    ART_VFL_DAT_FLG nvarchar(10) NULL,
    ART_VFL1_DAT nvarchar(50) NULL,
    ART_VFL1_MNG nvarchar(50) NULL,
    ART_VFL2_DAT nvarchar(50) NULL,
    ART_VFL2_MNG nvarchar(50) NULL,
    ART_VFL3_DAT nvarchar(50) NULL,
    ART_VFL3_MNG nvarchar(50) NULL,
    ART_VFL4_DAT nvarchar(50) NULL,
    ART_VFL4_MNG nvarchar(50) NULL,
    ART_MPLZ_FLG nvarchar(10) NULL,
    ART_MBOPT_FLG nvarchar(10) NULL,
    AM_SORT_BEZ nvarchar(200) NULL,
    GES_MAX_MBSTD_MNG nvarchar(50) NULL,
    REG_MAX_MBSTD_MNG nvarchar(50) NULL,
    ORG_FLG nvarchar(10) NULL,
    ORG_UMLAGER_DAT nvarchar(50) NULL,
    ORG_LORT_NR nvarchar(50) NULL,
    ORG_LORT_KURZ nvarchar(50) NULL,
    ORG_REG_MBSTD_MNG nvarchar(50) NULL,
    ORG_REG_KAP_MNG nvarchar(50) NULL,
    KD_BSTG_MNG nvarchar(50) NULL,
    ZUS_BSTG_MNG nvarchar(50) NULL,
    INV_GES_TERMIN nvarchar(50) NULL,
    INV_GES_BSTD_MNG nvarchar(50) NULL,
    INV_REG_TERMIN nvarchar(50) NULL,
    INV_REG_BSTD_MNG nvarchar(50) NULL
);

BULK INSERT dbo.B_LAGER_STG
FROM 'C:\temp\B_LAGER.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0A',
    TABLOCK,
    CODEPAGE = '65001'
);
GO
