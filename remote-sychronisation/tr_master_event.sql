USE [sync.a];
GO
CREATE TRIGGER tr_master_event
ON [sync.a].dbo.sync_events
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@node INT,
		@srv NVARCHAR(100),
		@db NVARCHAR(50),
		@sql NVARCHAR(MAX);

	DECLARE node_cur CURSOR LOCAL FAST_FORWARD FOR
		SELECT id, server_name, db_name
		FROM dbo.sync_nodes
		WHERE is_active = 1;

	OPEN node_cur;
	FETCH NEXT FROM node_cur INTO @node, @srv, @db;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS (SELECT 1 FROM inserted i WHERE i.source_id != @node)
		BEGIN
			SET @sql = N''; --Befehl
			EXEC sp_executesql @sql;
		END

		FETCH NEXT FROM node_cur INTO @node, @srv, @db;
	END
	
	CLOSE node_cur;
	DEALLOCATE node_cur;
END;