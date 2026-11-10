# percona_server

Installs Percona Server and optionally configures it, access grants, and replication.

## Actions

* `:install`
* `:remove`

## Properties

* `version` - Percona major version, `8.0` or `8.4`. Default: `8.4`.
* `server_config` - Hash of server configuration values formerly provided by `node['percona']['server']`.
* `backup_config` - Hash of backup user settings.
* `extra_config` - Hash rendered as `node['percona']['conf']` compatibility data for templates.
* `main_config_file` - Platform default config path.
* `skip_passwords` - Skip password/grant management.
* `systemd_open_files_limit` - Override RHEL-family systemd `LimitNOFILE`.

## Example

```ruby
percona_server 'default' do
  server_config(
    datadir: '/data/mysql',
    root_password: 'change-me'
  )
end
```
