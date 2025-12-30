USE [sync.b];
DROP TRIGGER tr_person_name_change
GO
CREATE TRIGGER tr_node_person
ON [sync.b].dbo.person
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @INSERT TINYINT = 1;
	DECLARE @DELETE TINYINT = 2;
	DECLARE @UPDATE TINYINT = 3;
	DECLARE @state_open TINYINT = 1;
	DECLARE @node_id TINYINT = dbo.fn_GetLocalNode();
	SET @node_id = 2; --Bin auf meinem Server
	
	IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
	BEGIN
		INSERT INTO [sync.a].dbo.sync_events (tb_name, key_id, typ, state, source_id, timestamp)
		SELECT 'person', id, @INSERT, @state_open, @node_id, GETDATE() FROM inserted
	END

	ELSE IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
	BEGIN
		INSERT INTO [sync.a].dbo.sync_events (tb_name, key_id, typ, state, source_id, timestamp)
		SELECT 'person', id, @DELETE, @state_open, @node_id, GETDATE() FROM deleted
	END

	ELSE IF EXISTS (SELECT 1 FROM inserted i JOIN deleted d ON i.id = d.id WHERE ISNULL(i.name, '') != ISNULL(d.name, ''))
	BEGIN
		INSERT INTO [sync.a].dbo.sync_events (tb_name, key_id, typ, state, source_id, timestamp)
		SELECT 'person', id, @UPDATE, @state_open, @node_id, GETDATE() FROM inserted
	END
END;