DECLARE @X XML;

DECLARE @Verordnung VARCHAR(MAX) =
(
    SELECT CAST([blob] AS VARCHAR(MAX))
    FROM RW_EREZEPT_Verordnung
    WHERE ERezeptID = '980.026.013.033.067.64'
);

DECLARE @Decoded VARBINARY(MAX) =
    CAST('' AS XML).value(
        'xs:base64Binary(sql:variable("@Verordnung"))',
        'VARBINARY(MAX)'
    );

DECLARE @Start INT = CHARINDEX('<Bundle',  @Decoded, 0);
DECLARE @End   INT = CHARINDEX('</Bundle>', @Decoded, 0) + 9;
DECLARE @Len   INT = @End - @Start;

SELECT @X =
    CAST(SUBSTRING(@Decoded, @Start, @Len) AS VARCHAR(MAX));

SELECT @X;
