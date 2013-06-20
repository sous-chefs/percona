chef_gem "chef-rewind"
require "chef/rewind"

include_recipe "percona::client"
include_recipe "mysql::server"

rewind :template => node['mysql']['grants_path'] do
  cookbook "percona"
end

rewind :template => "#{node['mysql']['conf_dir']}/my.cnf" do
  source "my.cnf.standalone.erb"
  cookbook "percona"
end

include_recipe "percona::replication"
