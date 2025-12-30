USE [Apobase]
GO

/****** Object:  StoredProcedure [dbo].[sp_VerbundPruefeKonfliktKundeKastell]    Script Date: 11.07.2025 17:45:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[sp_VerbundPruefeKonfliktKundeKastell] 	@diKdNr int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure her
	
	DECLARE @KdNr int
	PRINT 'Ho'
	SELECT @KdNr = dbo.FKT_TranslateKdNrToKastell(@diKdNr)

	
	SELECT COUNT(*) FROM [SERV4591469\SQLEXPRESS].Apobase.dbo.RW_MODUL_VerbundCacheKunde WHERE diKdNr = @KdNr

END



GO


