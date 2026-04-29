# frozen_string_literal: true

provides :percona_access_grants
unified_mode true

use '_partial/_config'

property :path, String, default: '/etc/mysql/grants.sql'

action_class do
  include Percona::Cookbook::Helpers

  def password_helper(_config)
    Percona::Cookbook::EncryptedPasswords.new(
      node,
      bag: new_resource.encrypted_data_bag,
      secret_file: new_resource.encrypted_data_bag_secret_file,
      mysql_item: new_resource.encrypted_data_bag_item_mysql,
      system_item: new_resource.encrypted_data_bag_item_system,
      use_chef_vault: new_resource.use_chef_vault
    )
  end
end

action :create do
  config = merged_percona_config(
    {
      'server' => new_resource.server_config,
      'backup' => new_resource.backup_config,
      'conf' => new_resource.extra_config,
      'main_config_file' => new_resource.main_config_file || percona_default_config_file,
      'auto_restart' => new_resource.auto_restart,
    },
    version: new_resource.version
  )
  apply_legacy_template_config(config)
  passwords = password_helper(config)
  server = config['server']
  backup = config['backup']

  directory ::File.dirname(new_resource.path) do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end

  template new_resource.path do
    source 'grants.sql.erb'
    variables(
      root_password: passwords.root_password(server['root_password']),
      debian_user: server['debian_username'],
      debian_password: passwords.debian_password(server['debian_username'], server['debian_password']),
      backup_password: passwords.backup_password(backup['username'], backup['password'])
    )
    owner 'root'
    group 'root'
    mode '0600'
    sensitive true
  end

  execute 'mysql-install-privileges' do
    command lazy {
      root_password = passwords.root_password(server['root_password']).to_s
      if root_password.empty?
        "/usr/bin/mysql < #{new_resource.path}"
      else
        "/usr/bin/mysql -p'#{root_password}' -e '' > /dev/null 2>&1; if [ $? -eq 0 ]; then /usr/bin/mysql -p'#{root_password}' < #{new_resource.path}; else /usr/bin/mysql < #{new_resource.path}; fi"
      end
    }
    action :nothing
    subscribes :run, "template[#{new_resource.path}]", :immediately
    sensitive true
  end
end

action :delete do
  file new_resource.path do
    action :delete
  end
end
