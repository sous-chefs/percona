# percona_backup

Installs Percona XtraBackup and optionally manages backup grants.

## Actions

* `:install`
* `:remove`

## Properties

* `version` - Percona major version, `8.0` or `8.4`. Default: `8.4`.
* `backup_config` - Backup username/password settings.
* `configure_grants` - Manage `/etc/mysql/grants.sql`. Default: `true`.

## Example

```ruby
percona_backup 'default' do
  backup_config(username: 'backup', password: 'change-me')
end
```
