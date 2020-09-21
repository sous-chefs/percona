::Chef::DSL::Recipe.include HashedPassword::Helper

node.default['percona']['skip_passwords'] = true
node.default['percona']['server']['debian_username'] = 'root'
node.default['percona']['server']['debian_password'] = ''
include_recipe 'percona::server'

# Create a schema to test mysql_database :drop against
bash 'create datatrout' do
  code <<-EOF
  echo 'CREATE SCHEMA datatrout;' | /usr/bin/mysql -u root;
  touch /tmp/troutmarker
  EOF
  not_if { ::File.exist?('/tmp/troutmarker') }
  action :run
end

# Create a database for testing existing grant operations
bash 'create datasalmon' do
  code <<-EOF
  echo 'CREATE SCHEMA datasalmon;' | /usr/bin/mysql -u root;
  touch /tmp/salmonmarker
  EOF
  not_if { ::File.exist?('/tmp/salmonmarker') }
  action :run
end

# Create a user to test mysql_database_user :drop against
bash 'create kermit' do
  code <<-EOF
  echo "CREATE USER 'kermit'@'localhost';" | /usr/bin/mysql -u root;
  touch /tmp/kermitmarker
  EOF
  not_if { ::File.exist?('/tmp/kermitmarker') }
  action :run
end

# Create a user to test mysql_database_user password update via :create
bash 'create rowlf' do
  code <<-EOF
  echo "CREATE USER 'rowlf'@'localhost' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root;
  touch /tmp/rowlfmarker
  EOF
  not_if { ::File.exist?('/tmp/rowlfmarker') }
  action :run
end

# Create a user to test mysql_database_user password update via :create using a password hash
bash 'create statler' do
  code <<-EOF
  echo "CREATE USER 'statler'@'localhost' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root;
  touch /tmp/statlermarker
  EOF
  not_if { ::File.exist?('/tmp/statlermarker') }
  action :run
end

# Create a user to test mysql_database_user password update via :grant
bash 'create rizzo' do
  code <<-EOF
  echo "CREATE USER 'rizzo'@'127.0.0.1' IDENTIFIED BY 'hunter2'; GRANT SELECT ON datasalmon.* TO 'rizzo'@'127.0.0.1';" | /usr/bin/mysql -u root;
  touch /tmp/rizzomarker
  EOF
  not_if { ::File.exist?('/tmp/rizzomarker') }
  action :run
end

## Resources we're testing
percona_database 'databass' do
  action :create
  password ''
end

percona_database 'datatrout' do
  action :drop
  password ''
end

percona_user 'piggy' do
  action :create
  ctrl_password ''
end

percona_user 'kermit' do
  action :drop
  ctrl_password ''
end

percona_user 'rowlf' do
  password '123456' # hashed: *6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9
  ctrl_password ''
  action :create
end

percona_user 'gonzo' do
  password 'abcdef'
  ctrl_password ''
  host '10.10.10.%'
  action :create
end

# create gonzo again to ensure the create action is idempotent
percona_user 'gonzo' do
  password 'abcdef'
  ctrl_password ''
  host '10.10.10.%'
  action :create
end

hash = hashed_password('*2027D9391E714343187E07ACB41AE8925F30737E'); # 'l33t'

percona_user 'statler' do
  password hash
  ctrl_password ''
  action :create
end

percona_user 'fozzie' do
  database_name 'databass'
  password 'wokkawokka'
  host 'mars'
  privileges [:select, :update, :insert]
  require_ssl true
  ctrl_password ''
  action [:create, :grant]
end

hash2 = hashed_password('*F798E7C0681068BAE3242AA2297D2360DBBDA62B'); # 'zokkazokka'

percona_user 'moozie' do
  database_name 'databass'
  password hash2
  ctrl_password ''
  host '127.0.0.1'
  privileges [:select, :update, :insert]
  require_ssl false
  action [:create, :grant]
end

# all the grants exist ('Granting privs' should not show up), but the password is different
# and should get updated
percona_user 'rizzo' do
  database_name 'datasalmon'
  password 'salmon'
  ctrl_password ''
  host '127.0.0.1'
  privileges [:select]
  require_ssl false
  action :grant
end

# Should converge normally for all versions
# Checks to insure SHA2 password algo works for percona 8
# with the host set to localhost
percona_user 'beaker' do
  password 'meep'
  host 'localhost'
  ctrl_password ''
  use_native_auth false
  action :create
end

percona_database 'flush privileges' do
  database_name 'databass'
  password ''
  sql 'flush privileges'
  action :query
end
