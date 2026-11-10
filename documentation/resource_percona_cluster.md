# percona_cluster

Installs Percona XtraDB Cluster and renders cluster-aware server configuration.

## Actions

* `:install`
* `:remove`

## Properties

* `cluster_config` - Hash of wsrep settings.
* `server_config` - Server configuration hash.
* `backup_config` - Backup user settings.

## Example

```ruby
percona_cluster 'default' do
  cluster_config(
    wsrep_cluster_name: 'prod',
    wsrep_cluster_address: 'gcomm://10.0.0.11,10.0.0.12,10.0.0.13'
  )
end
```
