/****** Object:  UserDefinedFunction [dbo].[FKT_TranslateKdNrFromRoemer]    Script Date: 12/07/2025 12:13:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--- Kastell
CREATE FUNCTION [dbo].[FKT_TranslateKdNrFromRoemer](@diKdNr int)
RETURNS int
AS
BEGIN 
	DECLARE @ret int

	-- Add the T-SQL statements to compute the return value here
	
	SELECT @ret = diKdNrAuto FROM RW_APOBASE_Kunde WHERE strIdent  = 'Verbund_Roemer' AND diKdNr = @diKdNr
	IF @@ROWCOUNT = 0
	BEGIN
		SELECT @ret = diKdNr FROM TempKundeHistorieAbgleich WHERE diKdNrAuto = @diKdNr AND strIdent LIKE 'Verbund_Kastell'
		IF @@ROWCOUNT = 0
		BEGIN 
			SELECT @ret = ISNULL(diKdNrAuto,0) FROM RW_APOBASE_Kunde WHERE diKdNr = (SELECT diKdNr FROM TempKundeHistorieAbgleich WHERE diKdNrAuto = @diKdNr AND strIdent LIKE 'Verbund_Gruene') AND strIdent LIKE 'Verbund_Gruene'	
		END
	END
	RETURN @ret
END

GO


