# set the server root password
# (it starts out blank after package installation)
execute %Q(mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('#{node["percona"]["server"]["root_password"]}');") do
  returns [0, 1] # in case password is already set
end

# macro to execute mysql statements via CLI
mysql = %Q(mysql -p"#{node["percona"]["server"]["root_password"]}" -e)

# delete non-local root users
execute %Q(#{mysql} "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');")

# execute grants

# debian-sys-maint user for administration
[['SELECT', 'mysql.user'], ['SHUTDOWN', '*.*']].each do |priv, loc|
  execute %Q(#{mysql} "GRANT #{priv} ON #{loc} TO '#{node["percona"]["server"]["debian_username"]}'@localhost IDENTIFIED BY '#{node["percona"]["server"]["debian_password"]}';") do
    only_if { node["platform_family"] == "debian" }
  end
end

if node["percona"]["backup"]["configure"]
  # Grant permissions for the XtraBackup user
  # Ensure the user exists, then revoke all grants, then re-grant specific permissions
  execute %Q(#{mysql} "GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '#{node["percona"]["backup"]["username"]}'@'localhost' IDENTIFIED BY '#{node["percona"]["backup"]["password"]}';")
  execute %Q(#{mysql} "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '#{node["percona"]["backup"]["username"]}'@'localhost';")
  execute %Q(#{mysql} "GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '#{node["percona"]["backup"]["username"]}'@'localhost' IDENTIFIED BY '#{node["percona"]["backup"]["password"]}';")
end

# flush privileges
execute %Q(#{mysql} "FLUSH PRIVILEGES;")
