USE [renz.roemer]
GO

/****** Object:  UserDefinedFunction [dbo].[sp_TranslateLfdNrToRemote]    Script Date: 12/07/2025 12:34:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[sp_TranslateLfdNrToRemote]
(
	-- Add the parameters for the function here
	@diLfdNr int,
	@strVerbund nvarchar(50)
)
RETURNS int
AS
BEGIN
	IF LEN(@strVerbund) <> 0
	BEGIN 
		SELECT @diLfdNr = diLfdNrHistorieVerbund FROM RW_APOBASE_Historie WHERE diLfdNr = @diLfdNr
	END 
	RETURN @diLfdNr
END
GO


