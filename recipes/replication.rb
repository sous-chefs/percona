require 'shellwords'

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

root_pass = passwords.root_password.to_s
root_pass = Shellwords.escape(root_pass).prepend('-p') unless root_pass.empty?

execute "mysql-set-replication" do
  command "/usr/bin/mysql #{root_pass} < /etc/mysql/replication.sql"
  action :nothing
  subscribes :run, resources("template[/etc/mysql/replication.sql]"), :immediately
end
