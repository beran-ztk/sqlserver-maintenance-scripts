USE [Apobase]
GO

/****** Object:  StoredProcedure [dbo].[sp_VerbundPruefeKonfliktKunde]    Script Date: 11.07.2025 17:45:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_VerbundPruefeKonfliktKunde] 	@diKdNr int, @remotePartner varchar(100), @remoteSP varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure her
	
	DECLARE @sqlCommand varchar(1000)
	DECLARE @remoteSP_withVal varchar(100)
	SET @remoteSP_withVal = @remoteSP + '(' + CAST( @diKdNr as varchar(10) ) + ')'
	

	SET @sqlCommand = 'SELECT COUNT(*) from ' + @remotePartner + '.[dbo].[RW_MODUL_VerbundCacheKunde] WHERE diKdNr = ' + @remoteSP_withVal
	EXEC (@sqlCommand)

END


GO


