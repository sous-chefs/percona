#
# Cookbook:: percona
# Recipe:: configure_server
#

percona_config 'Configure Server' do
  jemalloc          node['percona']['server']['jemalloc']
  interface         node['percona']['server']['bind_to']
  username          node['percona']['server']['username']
  slow_query_logdir node['percona']['server']['slow_query_logdir']
  datadir           node['percona']['server']['datadir']
  logdir            node['percona']['server']['logdir']
  tmpdir            node['percona']['server']['tmpdir']
  includedir        node['percona']['server']['includedir']
  skip_passwords    node['percona']['skip_passwords']
  chef_vault        node['percona']['use_chef_vault']
  main_config_file  node['percona']['main_config_file']
  enable_ssl        node['percona']['server']['replication']['ssl_enabled']
  auto_restart      node['percona']['auto_restart']
end


