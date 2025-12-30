/****** Object:  UserDefinedFunction [dbo].[sp_TranslateLfdNrToLocal]    Script Date: 12/07/2025 12:33:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[sp_TranslateLfdNrToLocal]
(
	-- Add the parameters for the function here
	@diLfdNr int,
	@strVerbund nvarchar(50)
)
RETURNS int
AS
BEGIN
DECLARE @Ret int
	IF LEN(@strVerbund) <> 0
	BEGIN 
		SELECT @diLfdNr = diLfdNr FROM RW_APOBASE_Historie WHERE diLfdNrHistorieVerbund = @diLfdNr AND strVerbund = @strVerbund
	END
	RETURN @diLfdNr
END
GO