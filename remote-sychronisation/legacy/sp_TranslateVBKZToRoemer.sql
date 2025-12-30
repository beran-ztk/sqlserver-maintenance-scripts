USE [renz.kastell]
GO

/****** Object:  UserDefinedFunction [dbo].[sp_TranslateVBKZToRoemer]    Script Date: 12/07/2025 12:35:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[sp_TranslateVBKZToRoemer]
(
	-- Add the parameters for the function here
	@strVerbund nvarchar(50)
)
RETURNS nvarchar(50) 
AS
BEGIN
	IF LEN(@strVerbund) = 0 OR @strVerbund IS NULL
	BEGIN
		SET @strVerbund = 'Verbund_Kastell'
	END
	IF @strVerbund = 'Verbund_Roemer'
	BEGIN 
		SET @strVerbund = ''
	END
	RETURN @strVerbund
END
GO


