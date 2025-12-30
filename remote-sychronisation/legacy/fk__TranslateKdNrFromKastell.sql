/****** Object:  UserDefinedFunction [dbo].[FKT_TranslateKdNrFromKastell]    Script Date: 12/07/2025 12:32:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--- Roemer
CREATE FUNCTION [dbo].[FKT_TranslateKdNrFromKastell](@diKdNr int)
RETURNS int
AS
BEGIN 
	DECLARE @ret int

	-- Add the T-SQL statements to compute the return value here
	SELECT @ret = diKdNrAuto FROM RW_APOBASE_Kunde WHERE diKdNr = @diKdNr AND strIdent LIKE 'Verbund_Kastell'
	
	IF @@ROWCOUNT = 0
	BEGIN
		SELECT @ret = diKdNr FROM TempKundeHistorieAbgleich WHERE diKdNrAuto = @diKdNr AND strIdent LIKE 'Verbund_Roemer'
		IF @@ROWCOUNT = 0
		BEGIN 
			SELECT @ret = ISNULL(diKdNrAuto,0) FROM RW_APOBASE_Kunde WHERE diKdNr = (SELECT diKdNr FROM TempKundeHistorieAbgleich WHERE diKdNrAuto = @diKdNr AND strIdent LIKE 'Verbund_Gruene') AND strIdent LIKE 'Verbund_Gruene'	
		END
	END
	RETURN @ret
END	
GO