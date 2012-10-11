percona = node["percona"]
server  = percona["server"]
conf    = percona["conf"]
mysqld  = (conf && conf["mysqld"]) || {}

# construct an encrypted passwords helper -- giving it the node and bag name
passwords = EncryptedPasswords.new(node, percona["encrypted_data_bag"])

if server['bind_to']
  ipaddr = Percona::ConfigHelper.bind_to(node, server['bind_to'])
  if ipaddr && server['bind_address'] != ipaddr
    node.override['percona']['server']['bind_address'] = ipaddr
    node.save
  end

  log "Can't find ip address for #{server['bind_to']}" do
    level :warn
    only_if { ipaddr.nil? }
  end
end

datadir = mysqld["datadir"] || server["datadir"]
user    = mysqld["user"] || server["user"]

# define the service
service "mysql" do
  supports :restart => true
  action :enable
end

# this is where we dump sql templates for replication, etc.
directory "/etc/mysql" do
  owner "root"
  group "root"
  mode 0755
end

# setup the main server config file
template percona["main_config_file"] do
  source "my.cnf.#{conf ? "custom" : server["role"]}.erb"
  owner "root"
  group "root"
  mode 0744
  notifies :restart, "service[mysql]", :immediately
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
template "/etc/mysql/debian.cnf" do
  source "debian.cnf.erb"
  variables(:debian_password => passwords.debian_password)
  owner "root"
  group "root"
  mode 0744
  notifies :restart, "service[mysql]", :immediately

  only_if { node["platform_family"] == "debian" }
end
