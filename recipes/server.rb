include_recipe "percona::default"

# helper
def mysql_initial_install?
  ! ::File.exists?("/usr/bin/mysql")
end

# install packages
package "percona-server-server" do
  options "--force-yes"
end

# define the service
service "mysql" do
  supports :restart => true
  action [:enable, :start]
end

# construct an encrypted passwords helper -- giving it the node and bag name
passwords = EncryptedPasswords.new( node, node[:percona][:encrypted_data_bag] )

# set initial root password
#if mysql_initial_install?
  # now let's set the root password
  execute "Update MySQL root password" do
    command "mysqladmin -u root password '#{passwords.root_password}'"
  end
#end

# setup the data directory
directory node[:percona][:server][:datadir] do
  owner node[:percona][:server][:username]
  group node[:percona][:server][:username]
  action :create
end

# install db to the data directory
execute "setup mysql datadir" do
  command "mysql_install_db --user=mysql --datadir=#{node[:percona][:server][:datadir]}"
  not_if { ::File.exists?("#{node[:percona][:server][:datadir]}/mysql/user.frm") }
end

# setup the main server config file
template "/etc/mysql/my.cnf" do
  source "my.cnf.#{node[:percona][:server][:role]}.erb"
  variables( :old_passwords => passwords.old_passwords )
  owner "root"
  group "root"
  mode 0744
  notifies :restart, resources(:service => "mysql")
end

# setup the debian system user config
template "/etc/mysql/debian.cnf" do
  source "debian.cnf.erb"
  variables( :debian_password => passwords.debian_password )
  owner "root"
  group "root"
  mode 0744
  notifies :restart, resources(:service => "mysql")
end

# access grants
include_recipe "percona::access_grants"
