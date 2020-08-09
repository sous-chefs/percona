node.default['percona']['server']['role'] = %w(master)
node.default['percona']['server']['replication']['host'] = 'master-host'
node.default['percona']['server']['replication']['username'] = 'replication'
node.default['percona']['server']['replication']['password'] = ')6$W2M{/'
node.default['percona']['server']['replication']['ssl_enabled'] = true

include_recipe 'test::server'
