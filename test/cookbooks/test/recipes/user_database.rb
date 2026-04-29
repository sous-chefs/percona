# frozen_string_literal: true

extend Percona::Cookbook::HashedPassword::Helper

server_config = {
  datadir: '/tmp/mysql',
  debian_username: 'root',
  debian_password: '',
  root_password: '',
}

include_recipe 'test::_remove_mysql_common'

percona_version = node['percona']['version'] || '8.4'

percona_server 'resources' do
  version percona_version
  server_config server_config
  skip_passwords true
end

bash 'create datatrout' do
  code <<~SH
    echo 'CREATE SCHEMA datatrout;' | /usr/bin/mysql -u root;
    touch /tmp/troutmarker
  SH
  not_if { ::File.exist?('/tmp/troutmarker') }
end

bash 'create datasalmon' do
  code <<~SH
    echo 'CREATE SCHEMA datasalmon;' | /usr/bin/mysql -u root;
    touch /tmp/salmonmarker
  SH
  not_if { ::File.exist?('/tmp/salmonmarker') }
end

bash 'create kermit' do
  code <<~SH
    echo "CREATE USER 'kermit'@'localhost';" | /usr/bin/mysql -u root;
    touch /tmp/kermitmarker
  SH
  not_if { ::File.exist?('/tmp/kermitmarker') }
end

bash 'create rowlf' do
  code <<~SH
    echo "CREATE USER 'rowlf'@'localhost' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root;
    touch /tmp/rowlfmarker
  SH
  not_if { ::File.exist?('/tmp/rowlfmarker') }
end

bash 'create statler' do
  code <<~SH
    echo "CREATE USER 'statler'@'localhost' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root;
    touch /tmp/statlermarker
  SH
  not_if { ::File.exist?('/tmp/statlermarker') }
end

bash 'create rizzo' do
  code <<~SH
    echo "CREATE USER 'rizzo'@'127.0.0.1' IDENTIFIED BY 'hunter2'; GRANT SELECT ON datasalmon.* TO 'rizzo'@'127.0.0.1';" | /usr/bin/mysql -u root;
    touch /tmp/rizzomarker
  SH
  not_if { ::File.exist?('/tmp/rizzomarker') }
end

bash 'create beauregard' do
  code <<~SH
    echo "CREATE USER 'beauregard'@'localhost' IDENTIFIED BY '>mupp3ts'; GRANT ALL PRIVILEGES ON *.* TO 'beauregard'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" | /usr/bin/mysql -u root;
    touch /tmp/beauregardmarker
  SH
  not_if { ::File.exist?('/tmp/beauregardmarker') }
end

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
  password '123456'
  ctrl_password ''
  action :create
end

percona_mysql_user 'gonzo' do
  password 'abcdef'
  ctrl_password ''
  host '10.10.10.%'
  action :create
end

percona_mysql_user 'statler' do
  password percona_hashed_password('*2027D9391E714343187E07ACB41AE8925F30737E')
  ctrl_password ''
  action :create
end

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

percona_mysql_user 'moozie' do
  database_name 'databass'
  password percona_hashed_password('*F798E7C0681068BAE3242AA2297D2360DBBDA62B')
  ctrl_password ''
  host '127.0.0.1'
  privileges [:select, :update, :insert]
  action [:create, :grant]
end

percona_mysql_database 'flush privileges' do
  database_name 'databass'
  password ''
  sql 'flush privileges'
  action :query
end
