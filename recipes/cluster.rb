include_recipe "percona::default"

# helper
def mysql_initial_install?
  ! ::File.exists?("/usr/bin/mysql")
end

# install packages
package "percona-xtradb-cluster-server-5.5" do
  options "--force-yes"
end

# define the service
service "mysql" do
  supports :restart => true
  action [:enable, :start]
end

percona = node["percona"]
server  = percona["server"]
conf    = percona["conf"]
mysqld  = (conf && conf["mysqld"]) || {}

# construct an encrypted passwords helper -- giving it the node and bag name
passwords = EncryptedPasswords.new(node, percona["encrypted_data_bag"])

datadir = mysqld["datadir"] || server["datadir"]
user    = mysqld["user"] || server["user"]

# set initial root password
if mysql_initial_install?
  # now let's set the root password
  execute "Update MySQL root password" do
    command "mysqladmin -u root password '#{passwords.root_password}'"
  end
end

# setup the data directory
directory datadir do
  owner user
  group user
  action :create
end

# install db to the data directory
execute "setup mysql datadir" do
  command "mysql_install_db --user=#{user} --datadir=#{datadir}"
  not_if { ::File.exists?("#{datadir}/mysql/user.frm") }
end

# setup the main server config file
template "/etc/my.cnf" do
  source "my.cnf.#{conf ? "custom" : node["percona"]["server"]["role"]}.erb"
  owner "root"
  group "root"
  mode 0744
  notifies :restart, resources(:service => "mysql")
end

# setup the debian system user config
template "/etc/mysql/debian.cnf" do
  source "debian.cnf.erb"
  variables(:debian_password => passwords.debian_password)
  owner "root"
  group "root"
  mode 0744
  notifies :restart, resources(:service => "mysql")
end

# access grants
include_recipe "percona::access_grants"
