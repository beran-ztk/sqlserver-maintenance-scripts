USE [Apobase]
GO

/****** Object:  StoredProcedure [dbo].[sp_VerbundPruefeKonfliktKundeGruene]    Script Date: 11.07.2025 17:45:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[sp_VerbundPruefeKonfliktKundeGruene] 	@diKdNr int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure her
	
	DECLARE @KdNr int
	SELECT @KdNr = dbo.FKT_TranslateKdNrToGruene(@diKdNr)

	SELECT COUNT(*) FROM [192.168.114.101\SQLEXPRESS].Apobase.dbo.RW_MODUL_VerbundCacheKunde WHERE diKdNr = @KdNr

END



GO


