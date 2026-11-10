# percona_access_grants

Renders and applies the SQL grant file used for root, Debian maintenance, and backup access.

## Actions

* `:create`
* `:delete`

## Properties

* `path` - Grant SQL path. Default: `/etc/mysql/grants.sql`.
* `server_config` - Root and Debian user/password settings.
* `backup_config` - Backup user/password settings.
* encrypted data bag properties - Optional secret source for passwords.
