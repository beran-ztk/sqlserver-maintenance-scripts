CREATE FUNCTION dbo.fn_GetLocalNode()
RETURNS INT
AS
BEGIN
	DECLARE @id TINYINT;

	SELECT TOP 1 @id = id 
	FROM [sync.a].dbo.sync_nodes
	WHERE server_name = @@SERVERNAME;

	IF @id IS NULL
		SET @id = 0

	RETURN @id
END;