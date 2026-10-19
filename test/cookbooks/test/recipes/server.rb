# frozen_string_literal: true

include_recipe 'test::_remove_mysql_common'

common_server_config = {
  datadir: '/tmp/mysql',
  debian_password: '0kb)F?Zj',
  root_password: '7tCk(V5I',
  jemalloc: !(platform_family?('rhel') && node['platform_version'] >= '9'),
}

percona_version = node['percona'] ? node['percona']['version'] || '8.4' : '8.4'

percona_server 'default' do
  version percona_version
  server_config common_server_config
  backup_config(password: 'I}=sJ2bS')
end

percona_backup 'default' do
  version percona_version
  server_config common_server_config
  backup_config(password: 'I}=sJ2bS')
end

package 'postfix' if platform_family?('rhel')
