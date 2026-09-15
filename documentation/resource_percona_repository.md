# percona_repository

Configures Percona APT or YUM repositories for supported Percona Server or XtraDB Cluster versions.

## Actions

* `:create`
* `:delete`

## Properties

* `version` - Percona major version, `8.0` or `8.4`. Default: `8.4`.
* `cluster` - Enable XtraDB Cluster repository instead of Percona Server. Default: `false`.
* `apt_uri`, `apt_key` - APT repository settings.
* `yum_baseurl`, `yum_gpgkey`, `yum_gpgcheck`, `yum_sslverify` - YUM repository settings.

## Example

```ruby
percona_repository 'default'
```
