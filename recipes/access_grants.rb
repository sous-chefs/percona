passwords = EncryptedPasswords.new(node, node["percona"]["encrypted_data_bag"])

# define access grants
template "/etc/mysql/grants.sql" do
  source "grants.sql.erb"
  variables(
    :root_password        => passwords.root_password,
    :debian_user          => node["percona"]["server"]["debian_username"],
    :debian_password      => passwords.debian_password,
    :backup_password      => passwords.backup_password
  )
  owner "root"
  group "root"
  mode "0600"
end

# execute access grants
execute "mysql-install-privileges" do
  command "/usr/bin/mysql < /etc/mysql/grants.sql"
  action :nothing
  subscribes :run, "template[/etc/mysql/grants.sql]", :immediately
end
