# percona_ssl

Writes SSL files used for SSL replication.

## Actions

* `:create`
* `:delete`

## Properties

* `certs_path` - Default: `/etc/mysql/ssl`.
* `certificates` - Hash containing `ca-cert`, `server`, and `client` certificate data. If omitted, the resource loads the configured data bag item.
* `server_roles` - Roles that decide whether server and client certs are written.
