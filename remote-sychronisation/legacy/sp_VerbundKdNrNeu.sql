USE [Apobase]
GO

/****** Object:  StoredProcedure [dbo].[sp_VerbundKdNrNeu]    Script Date: 11.07.2025 17:44:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Florian Horzella, david Dorst>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_VerbundKdNrNeu]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--DECLARE @MyCounter int;
--DECLARE @MydiKdNrAuto int;
--DECLARE @MydiKdNr int
--DECLARE @MydiKdNrHpt int;
--SET @MyCounter = 0;
--SET @MydiKdNrAuto = 0;
--SET @MydiKdNr =0;
--SET @MydiKdNrHpt = 0;	


--DECLARE diKdNr_Cursor CURSOR FOR
--SELECT diKdNrAuto
--FROM RW_APOBASE_Kunde
--WHERE strIdent LIKE '%Verbund%' AND bgeloescht = 0 AND diKdNr = 0;
--OPEN diKdNr_Cursor;
--FETCH NEXT FROM diKdNr_Cursor
--INTO @mydiKdNrAuto;

--WHILE @@FETCH_STATUS = 0
--	BEGIN
--	SELECT @MydiKdNrHpt = (SELECT diKdNrHpt FROM RW_APOBASE_Kunde WHERE diKdNrAuto = @MydiKdNrAuto);
--		UPDATE RW_APOBASE_Kunde
--		SET diKdNrHpt = (SELECT diKdNrAuto FROM RW_APOBASE_Kunde WHERE diKdNr = @MydiKdNrHpt)
--		WHERE diKdNrAuto = @MydiKdNrAuto
--	FETCH NEXT FROM diKdNr_Cursor
--	INTO @mydiKdNrAuto;
--	SET @MyCounter = @MyCounter + 1;
--	Print @MyCounter
--	END;
--CLOSE diKdNr_Cursor;
--DEALLOCATE diKdNr_Cursor;

END




GO


