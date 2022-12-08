node.default['percona']['server']['datadir'] = '/tmp/mysql'
node.default['percona']['server']['debian_password'] = '0kb)F?Zj'
node.default['percona']['server']['jemalloc'] = true
node.default['percona']['server']['root_password'] = '7tCk(V5I'
node.default['percona']['backup']['password'] = 'I}=sJ2bS'

# Install postfix on RHEL to ensure we don't properly break mysql-libs compatibility
package 'postfix' if platform_family?('rhel')

include_recipe 'test::_remove_mysql_common'
include_recipe 'percona::cluster'
