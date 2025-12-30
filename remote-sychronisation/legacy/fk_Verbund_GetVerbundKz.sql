USE [renz.roemer]
GO

/****** Object:  UserDefinedFunction [dbo].[FKT_Verbund_GetVerbundKz]    Script Date: 12/07/2025 12:06:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[FKT_Verbund_GetVerbundKz]
(		
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT strVerbund FROM RW_APOBASE_Kunde GROUP BY strVerbund
)
GO


