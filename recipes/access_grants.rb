#
# Cookbook Name:: percona
# Recipe:: access_grants
#

passwords = EncryptedPasswords.new(node, node["percona"]["encrypted_data_bag"])

# define access grants
template "/etc/mysql/grants.sql" do
  source "grants.sql.erb"
  variables(
    root_password: passwords.root_password,
    debian_user: node["percona"]["server"]["debian_username"],
    debian_password: passwords.debian_password,
    backup_password: passwords.backup_password
  )
  owner "root"
  group "root"
  mode "0600"
  sensitive true
end

# execute access grants
if passwords.root_password && !passwords.root_password.empty?
  # Stop the server, start it without grant tables, set grants, start regular server back
  execute "mysql-install-privileges" do
    command [
      "/usr/sbin/service mysql stop",
      "/usr/sbin/mysqld --skip-grant-tables --skip-networking --daemonize --pid-file=/tmp/mysqld-tmp.pid &> /dev/null > /dev/null &> /dev/null",
      "/usr/bin/sleep 10",
      "/usr/bin/mysql < /etc/mysql/grants.sql",
      "/usr/bin/kill `cat /tmp/mysqld-tmp.pid`",
      "/usr/sbin/service mysql start",
    ].join(" && ")
    action :nothing
    subscribes :run, resources("template[/etc/mysql/grants.sql]"), :immediately
  end
else
  # Simpler path...  just try running the grants command
  execute "mysql-install-privileges" do
    command "/usr/bin/mysql < /etc/mysql/grants.sql"
    action :nothing
    subscribes :run, resources("template[/etc/mysql/grants.sql]"), :immediately
  end
end
