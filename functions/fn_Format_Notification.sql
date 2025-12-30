USE [Apobase]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_Format_Notification](@val NVARCHAR(500))
RETURNS NVARCHAR(200)
AS
BEGIN
	DECLARE @cleaned NVARCHAR(500)

    SET @cleaned = SUBSTRING(@val, 0, CHARINDEX('  ', @val, 0))

    SET @cleaned = REPLACE(@cleaned, 'Bitte überprüfen Sie die Angaben mit Hilfe Ihres Warenwirtschaftssystemanbieters.', '')
    SET @cleaned = REPLACE(@cleaned, 'Bitte überprüfen Sie die Angaben in Ihrem Warenwirtschaftssystem.', '')
    SET @cleaned = REPLACE(@cleaned, 'Abgabedatensatz:  ', '')
    SET @cleaned = REPLACE(@cleaned, 'Verordnung: ', '')
    SET @cleaned = REPLACE(@cleaned, 'Abgabe: ', '')
    SET @cleaned = REPLACE(@cleaned, '.', '')
    SET @cleaned = REPLACE(@cleaned, '!', '')

    RETURN @cleaned
END
GO
