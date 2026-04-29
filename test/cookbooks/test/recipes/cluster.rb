# frozen_string_literal: true

include_recipe 'test::_remove_mysql_common'

server_config = {
  datadir: '/tmp/mysql',
  debian_password: '0kb)F?Zj',
  root_password: '7tCk(V5I',
  jemalloc: !(platform_family?('rhel') && node['platform_version'] >= '9'),
}

percona_version = node['percona']['version'] || '8.4'

percona_cluster 'default' do
  version percona_version
  server_config server_config
  backup_config(password: 'I}=sJ2bS')
end

package 'postfix' if platform_family?('rhel')
