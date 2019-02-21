#
# Cookbook:: percona
# Recipe:: server
#







  include_recipe 'percona::configure_server'


# access grants
unless node['percona']['skip_passwords']
  include_recipe 'percona::access_grants'
  include_recipe 'percona::replication'
end

pecona_server_install 'Server Install' do
  version = node['percona']['version']
end

unless node['percona']['skip_configure']

end
