include_recipe "percona::default"

# helper
def mysql_initial_install?
  ! ::File.exists?("/usr/bin/mysql")
end

# install packages
package "percona-server-server-5.1" do
  options "--force-yes"
end

# define the service
service "mysql" do
  supports :restart => true
  action [:enable, :start]
end

# set initial root password
if mysql_initial_install?
  execute "Update MySQL root password" do
    command "mysqladmin -u root password '#{node[:percona][:server][:root_password]}'"
  end
end

# setup the data directory
directory node[:percona][:server][:datadir] do
  owner "mysql"
  group "mysql"
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
  owner "root"
  group "root"
  mode 0744
  notifies :restart, resources(:service => "mysql")
end

# setup the debian system user config
template "/etc/mysql/debian.cnf" do
  source "debian.cnf.erb"
  owner "root"
  group "root"
  mode 0744
  notifies :restart, resources(:service => "mysql")
end

# define access grants
begin
  t = resources(:template => "/etc/mysql/grants.sql")
rescue
  Chef::Log.warn("Could not find previously defined grants.sql resource")
  t = template "/etc/mysql/grants.sql" do
    source "grants.sql.erb"
    owner "root"
    group "root"
    mode "0600"
    action :create
  end
end

# execute access grants
execute "mysql-install-privileges" do
  command "/usr/bin/mysql -u root -p#{node[:percona][:server][:root_password]} < /etc/mysql/grants.sql"
  action :nothing
  subscribes :run, resources(:template => "/etc/mysql/grants.sql"), :immediately
end
