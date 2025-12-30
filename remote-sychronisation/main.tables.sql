CREATE TABLE sync_nodes (
	id INT IDENTITY(1,1) PRIMARY KEY,
	user_name VARCHAR(50),
	server_name VARCHAR(100),
	db_name VARCHAR(50),
	is_active BIT,
	last_sync DATETIME,
	is_master BIT
)

CREATE TABLE sync_events (
	id INT IDENTITY(1,1),
	tb_name VARCHAR(50),
	key_id INT,
	typ TINYINT,
	state TINYINT,
	source_id TINYINT,
	timestamp DATETIME
)

CREATE TABLE person (
	id INT IDENTITY(1,1),
	name VARCHAR(50)
)