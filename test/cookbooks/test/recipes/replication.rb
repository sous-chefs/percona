# frozen_string_literal: true

include_recipe 'test::_remove_mysql_common'

server_config = {
  datadir: '/tmp/mysql',
  debian_password: '0kb)F?Zj',
  root_password: '7tCk(V5I',
  jemalloc: !(platform_family?('rhel') && node['platform_version'] >= '9'),
  role: %w(source),
  replication: {
    host: 'source-host',
    username: 'replication',
    password: ')6$W2M{/',
    ssl_enabled: true,
  },
}

percona_version = node['percona'] ? node['percona']['version'] || '8.4' : '8.4'

percona_server 'replication' do
  version percona_version
  server_config server_config
  backup_config(password: 'I}=sJ2bS')
end

percona_backup 'replication' do
  version percona_version
  server_config server_config
  backup_config(password: 'I}=sJ2bS')
end
