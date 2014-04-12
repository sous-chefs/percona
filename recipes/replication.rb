passwords = EncryptedPasswords.new(node, node["percona"]["encrypted_data_bag"])

server = node.percona.server

template "/etc/mysql/replication.sql" do
  source "replication_#{server.role}.sql.erb"
  variables replication_password: passwords.replication_password
  owner "root"
  group "root"
  mode 0600

  only_if { server.replication.host != "" or server.role == "master" }
end

# execute access grants
if passwords.root_password && !passwords.root_password.empty?
  execute "mysql-set-replication" do
    command "/usr/bin/mysql -p'" + passwords.root_password + "' -e '' &> /dev/null > /dev/null &> /dev/null ; if [ $? -eq 0 ] ; then /usr/bin/mysql -p'" + passwords.root_password + "' < /etc/mysql/replication.sql ; else /usr/bin/mysql < /etc/mysql/replication.sql ; fi ;"
    action :nothing
    subscribes :run, resources("template[/etc/mysql/replication.sql]"), :immediately
  end
else
  execute "mysql-set-replication" do
    command "/usr/bin/mysql < /etc/mysql/replication.sql"
    action :nothing
    subscribes :run, resources("template[/etc/mysql/replication.sql]"), :immediately
  end
end
