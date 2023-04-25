::Chef::DSL::Recipe.include Percona::Cookbook::HashedPassword::Helper

node.default['percona']['skip_passwords'] = true
node.default['percona']['server']['debian_username'] = 'root'
node.default['percona']['server']['debian_password'] = ''
include_recipe 'test::_remove_mysql_common'
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

# Create a user to test ctrl_user, ctrl_password, and ctrl_host
bash 'create beauregard' do
  code <<-EOF
  echo "CREATE USER 'beauregard'@'localhost' IDENTIFIED BY '>mupp3ts'; GRANT ALL PRIVILEGES ON *.* TO 'beauregard'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" | /usr/bin/mysql -u root;
  touch /tmp/beauregardmarker
  EOF
  not_if { ::File.exist?('/tmp/beauregardmarker') }
  action :run
end

# Create a user to test mysql_database_user password update via :create and non-root user
bash 'create waldorf@localhost' do
  code <<-EOF
  echo "CREATE USER 'waldorf'@'localhost' IDENTIFIED BY 'balcony';" | /usr/bin/mysql -u root;
  touch /tmp/waldorf_localhostmarker
  EOF
  not_if { ::File.exist?('/tmp/waldorf_localhostmarker') }
  action :run
end

# Create a user to test mysql_database_user password update via :create and non-root user
bash 'create waldorf' do
  code <<-EOF
  echo "CREATE USER 'waldorf'@'127.0.0.1' IDENTIFIED BY 'boxseat';" | /usr/bin/mysql -u root;
  touch /tmp/waldorf_127marker
  EOF
  not_if { ::File.exist?('/tmp/waldorf_127marker') }
  action :run
end

## Resources we're testing
percona_mysql_database 'databass' do
  action :create
  password ''
end

percona_mysql_database 'datatrout' do
  action :drop
  password ''
end

percona_mysql_user 'piggy' do
  action :create
  ctrl_password ''
end

percona_mysql_user 'kermit' do
  action :drop
  ctrl_password ''
end

percona_mysql_user 'rowlf' do
  password '123456' # hashed: *6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9
  ctrl_password ''
  action :create
end

percona_mysql_user 'gonzo' do
  password 'abcdef'
  ctrl_password ''
  host '10.10.10.%'
  action :create
end

# create gonzo again to ensure the create action is idempotent
percona_mysql_user 'gonzo' do
  password 'abcdef'
  ctrl_password ''
  host '10.10.10.%'
  action :create
end

hash = hashed_password('*2027D9391E714343187E07ACB41AE8925F30737E'); # 'l33t'

percona_mysql_user 'statler' do
  password hash
  ctrl_password ''
  action :create
end

# test global permissions
percona_mysql_user 'camilla' do
  password 'bokbokbok'
  privileges [:select, :repl_client, :create_tmp_table, :show_db]
  require_ssl true
  ctrl_password ''
  action [:create, :grant]
end

percona_mysql_user 'fozzie' do
  database_name 'databass'
  password 'wokkawokka'
  host 'mars'
  privileges [:select, :update, :insert]
  require_ssl true
  ctrl_password ''
  action [:create, :grant]
end

hash2 = hashed_password('*F798E7C0681068BAE3242AA2297D2360DBBDA62B'); # 'zokkazokka'

percona_mysql_user 'moozie' do
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
percona_mysql_user 'rizzo' do
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
percona_mysql_user 'beaker' do
  password 'meep'
  host 'localhost'
  ctrl_password ''
  use_native_auth false
  action :create
end

# Create new user with a ctrl_user as non-root to test ctrl_hash and validate ctrl_password with special character
percona_mysql_user 'bunsen' do
  database_name 'datasalmon'
  password 'honeydont'
  ctrl_user 'beauregard'
  ctrl_password '>mupp3ts'
  ctrl_host '127.0.0.1'
  host 'localhost'
  privileges [:select]
  action [:create, :grant]
end

percona_mysql_user 'waldorf' do
  password 'balcony'
  ctrl_user 'beauregard'
  ctrl_password '>mupp3ts'
  ctrl_host '127.0.0.1'
  host '127.0.0.1'
  action :create
end

percona_mysql_database 'flush privileges' do
  database_name 'databass'
  password ''
  sql 'flush privileges'
  action :query
end
