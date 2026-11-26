# Percona Cookbook Migration Guide

This release is a breaking migration from recipes and node attributes to custom resources.

## What Changed

* `recipes/` was removed. Wrapper cookbooks should declare resources directly.
* `attributes/` was removed. Resource properties replace `node['percona']` attributes.
* Percona 8.0 and 8.4 suites are both retained where upstream Percona still publishes supported packages. The 8.0 suites exclude newer platforms that Percona marks as 8.4-only, such as RHEL 10-compatible platforms and Debian 13.
* RHEL systemd service edits now use a `mysqld.service.d/limits.conf` drop-in instead of editing the vendor unit with line resources.

## Recipe Replacements

* `include_recipe 'percona::package_repo'` -> `percona_repository 'default'`
* `include_recipe 'percona::client'` -> `percona_client 'default'`
* `include_recipe 'percona::server'` -> `percona_server 'default'`
* `include_recipe 'percona::backup'` -> `percona_backup 'default'`
* `include_recipe 'percona::toolkit'` -> `percona_toolkit 'default'`
* `include_recipe 'percona::cluster'` -> `percona_cluster 'default'`
* `include_recipe 'percona::ssl'` -> `percona_ssl 'default'`

## Attribute Replacements

Pass values through resource properties:

```ruby
percona_server 'default' do
  version '8.4'
  server_config(
    datadir: '/data/mysql',
    root_password: 'change-me',
    debian_password: 'change-me',
    bind_address: '0.0.0.0'
  )
  backup_config(
    username: 'backup',
    password: 'change-me'
  )
end
```

SQL resources remain available:

```ruby
percona_mysql_database 'app' do
  password 'root-password'
end

percona_mysql_user 'app' do
  password 'user-password'
  database_name 'app'
  privileges [:select, :insert, :update]
  ctrl_password 'root-password'
  action [:create, :grant]
end
```

See `test/cookbooks/test/recipes/` for converged examples.
