passwords = EncryptedPasswords.new(node, node["percona"]["encrypted_data_bag"])

# define access grants
template "/etc/mysql/replication.sql" do
  source "replication.sql.erb"
  variables(
    :replication_password => passwords.replication_password
  )
  owner "root"
  group "root"
  mode "0600"

  only_if { node["percona"]["server"]["replication"]["host"] != "" || node["percona"]["server"]["role"] == "master" }
end

# execute access grants
execute "mysql-set-replication" do
  command "/usr/bin/mysql < /etc/mysql/replication.sql"
  action :nothing
  subscribes :run, "template[/etc/mysql/replication.sql]", :immediately
end
