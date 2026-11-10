# percona_replication

Renders and applies replication SQL.

## Actions

* `:create`
* `:delete`

## Properties

* `replication_sql` - SQL file path. Default: `/etc/mysql/replication.sql`.
* `server_config` - Replication host, port, username, password, SSL settings, and server role.
* encrypted data bag properties - Optional secret source for root and replication passwords.
