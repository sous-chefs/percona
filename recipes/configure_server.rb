percona = node["percona"]
server  = percona["server"]
conf    = percona["conf"]
mysqld  = (conf && conf["mysqld"]) || {}

# construct an encrypted passwords helper -- giving it the node and bag name
passwords = EncryptedPasswords.new(node, percona["encrypted_data_bag"])

datadir = mysqld["datadir"] || server["datadir"]
user    = mysqld["user"] || server["user"]

# define the service
service "mysql" do
  supports :restart => true
  action :enable
end

# setup the main server config file
template "/etc/my.cnf" do
  source "my.cnf.#{conf ? "custom" : server["role"]}.erb"
  owner "root"
  group "root"
  mode 0744
  notifies :restart, "service[mysql]", :immediately
end

# this is where we dump sql templates for replication, etc.
directory "/etc/mysql" do
  owner "root"
  group "root"
  mode 0755
end

# setup the data directory
directory datadir do
  owner user
  group user
  recursive true
  action :create
end

# now let's set the root password only if this is the initial install
execute "Update MySQL root password" do
  command "mysqladmin -u root password '#{passwords.root_password}'"
  not_if "test -f /etc/mysql/grants.sql"
end

# install db to the data directory
execute "setup mysql datadir" do
  command "mysql_install_db --user=#{user} --datadir=#{datadir}"
  not_if "test -f #{datadir}/mysql/user.frm"
end

# setup the debian system user config
if node["platform_family"] == "debian"
  template "/etc/mysql/debian.cnf" do
    source "debian.cnf.erb"
    variables(:debian_password => passwords.debian_password)
    owner "root"
    group "root"
    mode 0744
    notifies :restart, "service[mysql]", :immediately
  end
end
