USE [renz.roemer]
GO

/****** Object:  UserDefinedFunction [dbo].[sp_TranslateVBKZToGruene]    Script Date: 12/07/2025 12:34:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[sp_TranslateVBKZToGruene]
(
	-- Add the parameters for the function here
	@strVerbund nvarchar(50)
)
RETURNS nvarchar(50) 
AS
BEGIN
	IF LEN(@strVerbund) = 0 OR @strVerbund IS NULL
	BEGIN
		SET @strVerbund = 'Verbund_Roemer'
	END
	IF @strVerbund = 'Verbund_Gruene'
	BEGIN 
		SET @strVerbund = ''
	END
	RETURN @strVerbund
END
GO


