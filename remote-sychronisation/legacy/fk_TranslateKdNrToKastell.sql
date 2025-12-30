/****** Object:  UserDefinedFunction [dbo].[FKT_TranslateKdNrToKastell]    Script Date: 12/07/2025 12:33:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FKT_TranslateKdNrToKastell](@diKdNr int)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ret int

	-- Die Kundennummer Auto aus der Kastell
	SELECT @ret = diKdNr FROM RW_APOBASE_Kunde WHERE diKdNrAuto = @diKdNr AND strIdent LIKE 'Verbund_Kastell'
	

	IF @@ROWCOUNT = 0
	BEGIN
		-- Kundennummer aus der Roemer - Kastell
		SELECT @ret = ISNULL(diKdNrAuto,0) FROM [SERV4591469\SQLEXPRESS].[ApoBase].[dbo].[RW_APOBASE_Kunde] WHERE diKdNr = (SELECT diKdNrAuto FROM RW_APOBASE_Kunde WHERE diKdNrAuto = @diKdNr) AND strIdent LIKE 'Verbund_Roemer'
		IF @@ROWCOUNT = 0
		BEGIN 
			-- Kundennummr Auto der Roemer - Gruene
			SELECT @ret = ISNULL(diKdNrAuto,0) FROM [SERV4591469\SQLEXPRESS].[ApoBase].[dbo].[RW_APOBASE_Kunde] WHERE diKdNr = (SELECT diKdNr FROM RW_APOBASE_Kunde WHERE strIdent = 'Verbund_Gruene' AND diKdNrAuto = @diKdNr) AND strIdent LIKE 'Verbund_Gruene'
			IF @@ROWCOUNT = 0
			BEGIN 
				SET @ret = 0
			END
		END
	END

	-- Return the result of the function
	RETURN @Ret

END
GO