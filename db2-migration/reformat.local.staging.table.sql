DECLARE @current_table VARCHAR(50) = 'B_LAGER_temp';


DECLARE @sql NVARCHAR(MAX) = N'';

DECLARE @char_type_id INT = 175;
DECLARE @multiply_char_lenght_under_10_by INT = 10;
DECLARE @multiply_char_lenght_over_10_by INT = 3;

SELECT @sql += 
'ALTER TABLE ' + QUOTENAME(@current_table) + 
' ALTER COLUMN ' + QUOTENAME(name) + 
' CHAR(' + 
	CAST(
		CASE 
			WHEN max_length < 10 
				THEN max_length * @multiply_char_lenght_under_10_by
			ELSE max_length * @multiply_char_lenght_over_10_by
		END AS NVARCHAR(10)
	) + 
');'
FROM sys.all_columns 
WHERE object_id = OBJECT_ID(@current_table)
  AND system_type_id = @char_type_id
  AND max_length < 75;

DECLARE @decimal_type_id INT = 106;

EXECUTE sp_executesql @sql;
