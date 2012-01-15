# define access grants
template "/etc/mysql/grants.sql" do
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
end

# execute access grants
execute "mysql-install-privileges" do
  command "/usr/bin/mysql -u root -p#{node[:percona][:server][:root_password]} < /etc/mysql/grants.sql"
  action :nothing
  subscribes :run, resources(:template => "/etc/mysql/grants.sql"), :immediately
end
