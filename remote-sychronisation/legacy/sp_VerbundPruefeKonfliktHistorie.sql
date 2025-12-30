USE [Apobase]
GO

/****** Object:  StoredProcedure [dbo].[sp_VerbundPruefeKonfliktHistorie]    Script Date: 11.07.2025 17:44:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[sp_VerbundPruefeKonfliktHistorie] 	@diLfdNr int, @remotePartner varchar(100), @remoteSP varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure her
	
	DECLARE @sqlCommand varchar(1000)
	DECLARE @remoteSP_withVal varchar(100)
	SET @remoteSP_withVal = @remoteSP + '(' + CAST( @diLfdNr as varchar(10) ) + ')'
	

	SET @sqlCommand = 'SELECT COUNT(*) from ' + @remotePartner + '.[dbo].[RW_MODUL_VerbundCacheHistorie] WHERE diLfdNr = ' + @remoteSP_withVal
	EXEC (@sqlCommand)

END



GO


