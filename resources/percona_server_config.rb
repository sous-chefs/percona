# frozen_string_literal: true

provides :percona_server_config
unified_mode true

use '_partial/_config'

property :cluster, [true, false], default: false
property :selinux_module_url, String, default: ''

action_class do
  include Percona::Cookbook::Helpers

  def password_helper
    Percona::Cookbook::EncryptedPasswords.new(
      node,
      bag: new_resource.encrypted_data_bag,
      secret_file: new_resource.encrypted_data_bag_secret_file,
      mysql_item: new_resource.encrypted_data_bag_item_mysql,
      system_item: new_resource.encrypted_data_bag_item_system,
      use_chef_vault: new_resource.use_chef_vault
    )
  end

  def supports_old_passwords?
    Gem::Version.new(new_resource.version.to_s) < Gem::Version.new('8.0')
  end
end

action :create do
  config = merged_percona_config(
    {
      'server' => new_resource.server_config,
      'backup' => new_resource.backup_config,
      'cluster' => new_resource.cluster_config,
      'conf' => new_resource.extra_config,
      'main_config_file' => new_resource.main_config_file || percona_default_config_file,
      'auto_restart' => new_resource.auto_restart,
      'selinux_module_url' => new_resource.selinux_module_url,
    },
    version: new_resource.version,
    cluster_enabled: new_resource.cluster
  )
  apply_legacy_template_config(config)
  server = config['server']
  backup = config['backup']
  cluster = config['cluster']
  mysqld = config['conf']['mysqld'] || {}
  passwords = password_helper

  if server['bind_to']
    ipaddr = Percona::ConfigHelper.bind_to(node, server['bind_to'])
    if ipaddr && server['bind_address'] != ipaddr
      server['bind_address'] = ipaddr
      config['server']['bind_address'] = ipaddr
      apply_legacy_template_config(config)
    end

    log "Can't find ip address for #{server['bind_to']}" do
      level :warn
      only_if { ipaddr.nil? }
    end
  end

  unless new_resource.selinux_module_url.empty?
    semodule_filename = new_resource.selinux_module_url.split('/').last
    semodule_filepath = "#{Chef::Config[:file_cache_path]}/#{semodule_filename}"

    remote_file semodule_filepath do
      source new_resource.selinux_module_url
      only_if { semodule_filename && platform_family?('rhel') }
    end

    execute "semodule-install-#{semodule_filename}" do
      command "/usr/sbin/semodule -i #{semodule_filepath}"
      only_if { semodule_filename && platform_family?('rhel') }
      not_if "/usr/sbin/semodule -l | grep '^#{semodule_filename.split('.')[0..-2].join('.')}\\s'"
    end
  end

  package percona_jemalloc_package do
    only_if { server['jemalloc'] }
  end

  directory '/etc/mysql' do
    owner 'root'
    group 'root'
    mode '0755'
  end

  directory mysqld.fetch('datadir', server['datadir']) do
    owner mysqld.fetch('username', server['username'])
    group mysqld.fetch('username', server['username'])
    recursive true
  end

  directory 'log directory' do
    path mysqld.fetch('logdir', server['logdir'])
    owner mysqld.fetch('username', server['username'])
    group mysqld.fetch('username', server['username'])
    recursive true
  end

  directory mysqld.fetch('tmpdir', server['tmpdir']) do
    owner mysqld.fetch('username', server['username'])
    group mysqld.fetch('username', server['username'])
    recursive true
    not_if { mysqld.fetch('tmpdir', server['tmpdir']) == '/tmp' }
  end

  directory mysqld.fetch('includedir', server['includedir']) do
    owner mysqld.fetch('username', server['username'])
    group mysqld.fetch('username', server['username'])
    recursive true
    not_if { mysqld.fetch('includedir', server['includedir']).empty? }
  end

  directory 'slow query log directory' do
    path mysqld.fetch('slow_query_logdir', server['slow_query_logdir'])
    owner mysqld.fetch('username', server['username'])
    group mysqld.fetch('username', server['username'])
    recursive true
    not_if { mysqld.fetch('slow_query_logdir', server['slow_query_logdir']) == mysqld.fetch('logdir', server['logdir']) }
  end

  service 'mysql' do
    supports restart: true
    action server['enable'] ? :enable : :disable
  end

  execute 'setup mysql datadir' do
    command "mysqld --defaults-file=#{new_resource.main_config_file || percona_default_config_file} --user=#{mysqld.fetch('username', server['username'])} --initialize-insecure"
    not_if { ::File.exist?("#{mysqld.fetch('datadir', server['datadir'])}/mysql/user.frm") || ::File.exist?("#{mysqld.fetch('datadir', server['datadir'])}/mysql.ibd") }
    action :nothing
  end

  percona_ssl 'replication ssl' do
    version new_resource.version
    server_config server
    owner server['username']
    server_roles server['role']
    encrypted_data_bag new_resource.encrypted_data_bag
    encrypted_data_bag_item_ssl_replication new_resource.encrypted_data_bag_item_ssl_replication
    action :create
    only_if { server['replication']['ssl_enabled'] }
  end

  wsrep_sst_auth = if cluster && server['role'].include?('cluster') && cluster['wsrep_sst_auth'].empty?
                     "#{backup['username']}:#{passwords.backup_password(backup['username'], backup['password'])}"
                   else
                     cluster['wsrep_sst_auth'].to_s
                   end

  template new_resource.main_config_file || percona_default_config_file do
    cookbook 'percona'
    source server['role'].include?('cluster') ? 'my.cnf.cluster.erb' : 'my.cnf.main.erb'
    owner 'root'
    group 'root'
    mode '0644'
    sensitive true
    manage_symlink_source false
    force_unlink true
    variables(
      jemalloc_lib: percona_jemalloc_lib,
      wsrep_sst_auth: wsrep_sst_auth,
      old_passwords: supports_old_passwords? ? passwords.old_passwords(server['old_passwords']) : nil
    )
    notifies :run, 'execute[setup mysql datadir]', :immediately
    notifies :restart, 'service[mysql]', :immediately if new_resource.auto_restart
  end

  template '/root/.my.cnf' do
    cookbook 'percona'
    variables(root_password: passwords.root_password(server['root_password']))
    owner 'root'
    group 'root'
    mode '0600'
    source 'my.cnf.root.erb'
    sensitive true
    not_if { new_resource.skip_passwords }
  end

  execute 'Update MySQL root password' do
    command lazy { "mysql --user=root --password='' -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '#{passwords.root_password(server['root_password'])}';\"" }
    only_if "mysqladmin --user=root --password='' version"
    sensitive true
    not_if { new_resource.skip_passwords }
  end

  template '/etc/mysql/debian.cnf' do
    cookbook 'percona'
    source 'debian.cnf.erb'
    variables(debian_password: passwords.debian_password(server['debian_username'], server['debian_password']))
    owner 'root'
    group 'root'
    mode '0640'
    sensitive true
    notifies :restart, 'service[mysql]', :immediately if new_resource.auto_restart
    only_if { platform_family?('debian') }
  end
end

action :delete do
  file new_resource.main_config_file || percona_default_config_file do
    action :delete
  end

  file '/root/.my.cnf' do
    action :delete
  end

  file '/etc/mysql/debian.cnf' do
    action :delete
  end
end
