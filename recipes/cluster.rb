include_recipe "percona::default"

# install packages
package "percona-xtradb-cluster-server-5.5" do
  action :install
  options "--force-yes"
end

percona = node["percona"]
server  = percona["server"]
conf    = percona["conf"]
mysqld  = (conf && conf["mysqld"]) || {}

# construct an encrypted passwords helper -- giving it the node and bag name
passwords = EncryptedPasswords.new(node, percona["encrypted_data_bag"])

datadir = mysqld["datadir"] || server["datadir"]
user    = mysqld["user"] || server["user"]

cluster_nodes = search(:node, "chef_environment:#{node.chef_environment} AND percona_cluster_wsrep_cluster_name:#{node["percona"]["cluster"]["wsrep_cluster_name"]} NOT hostname:#{node["hostname"]}")

if related_node = cluster_nodes.first
  cluster_address = related_node["ipaddress"]
else
  cluster_address = ""
end

# now let's set the root password only if this is the initial install
execute "Update MySQL root password" do
  command "mysqladmin -u root password '#{passwords.root_password}'"
  not_if "test -f /etc/mysql/grants.sql"
end

# setup the data directory
directory datadir do
  owner user
  group user
  recursive true
  action :create
end

# install db to the data directory
execute "setup mysql datadir" do
  command "mysql_install_db --user=#{user} --datadir=#{datadir}"
  not_if "test -f #{datadir}/mysql/user.frm"
end

# setup the main server config file
template "/etc/my.cnf" do
  source "my.cnf.#{conf ? "custom" : "cluster"}.erb"
  variables(:cluster_address => cluster_address)
  owner "root"
  group "root"
  mode 0744
  notifies :restart, "service[mysql]", :immediately
end

# setup the debian system user config
template "/etc/mysql/debian.cnf" do
  source "debian.cnf.erb"
  variables(:debian_password => passwords.debian_password)
  owner "root"
  group "root"
  mode 0744
  notifies :restart, "service[mysql]", :immediately
end

# define the service
service "mysql" do
  supports :restart => true
  action [:enable, :start]
end

# access grants
include_recipe "percona::access_grants"
