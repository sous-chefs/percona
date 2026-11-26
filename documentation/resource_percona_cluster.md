# percona_cluster

Installs Percona XtraDB Cluster and renders cluster-aware server configuration.

## Actions

* `:install`
* `:remove`

## Properties

* `cluster_config` - Hash of wsrep settings.
* `server_config` - Server configuration hash.
* `backup_config` - Backup user settings.
* `bootstrap` - Use the package's `mysql@bootstrap` service to start the initial node. Default: `false`. Set it temporarily on the first node with `auto_restart true`. The cookbook leaves it disabled at boot and does not bootstrap an existing, stopped cluster. After other nodes join, clear the option, stop the bootstrap unit, and switch the first node to the normal MySQL service.

Percona XtraDB Cluster defaults to `xtrabackup-v2` for state snapshot transfers. Current PXC versions manage the transfer account internally. Update existing wrappers that still pass the retired `rsync` method or the removed `wsrep_sst_auth` and `innodb_locks_unsafe_for_binlog` settings.

## Example

```ruby
percona_cluster 'default' do
  cluster_config(
    wsrep_cluster_name: 'prod',
    wsrep_cluster_address: 'gcomm://10.0.0.11,10.0.0.12,10.0.0.13'
  )
end
```
