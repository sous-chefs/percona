node.default['percona']['server']['datadir'] = '/tmp/mysql'
node.default['percona']['server']['debian_password'] = '0kb)F?Zj'
node.default['percona']['server']['jemalloc'] = true
node.default['percona']['server']['root_password'] = '7tCk(V5I'
node.default['percona']['backup']['password'] = 'I}=sJ2bS'

include_recipe 'percona::server'
include_recipe 'percona::backup'
