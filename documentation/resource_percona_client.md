# percona_client

Installs Percona client packages.

## Actions

* `:install`
* `:remove`

## Properties

* `version` - Percona major version, `8.0` or `8.4`. Default: `8.4`.
* `cluster` - Install XtraDB Cluster client package. Default: `false`.
* `packages` - Override package list.
* `install_devel_package` - Install development headers. Default: `false`.
* `configure_repository` - Configure repositories before package install. Default: `true`.

## Example

```ruby
percona_client 'default' do
  install_devel_package true
end
```
