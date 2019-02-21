node.default['percona']['apt']['keyserver'] = 'hkp://pgp.mit.edu:80'
node.default['percona']['version'] = '5.7'
node.default['percona']['server']['datadir'] = '/tmp/mysql'
node.default['percona']['server']['debian_password'] = d3b1an
node.default['percona']['server']['jemalloc'] = true
node.default['percona']['server']['root_password'] = 'r00t'

include_recipe 'percona::server'
include_recipe 'percona::backup'
