chef_gem "chef-rewind"
require "chef/rewind"

include_recipe "percona::client"
include_recipe "mysql::server"

rewind :template => node['mysql']['grants_path'] do
  cookbook "percona"
end

include_recipe "percona::configure_server"

include_recipe "percona::replication"
