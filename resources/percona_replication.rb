# frozen_string_literal: true

provides :percona_replication
unified_mode true

require 'shellwords'

use '_partial/_config'

property :replication_sql, String, default: '/etc/mysql/replication.sql'

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
    },
    version: new_resource.version
  )
  config['server']['replication']['replication_sql'] = new_resource.replication_sql
  apply_legacy_template_config(config)
  server = config['server']
  passwords = password_helper

  directory ::File.dirname(new_resource.replication_sql) do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end

  template new_resource.replication_sql do
    cookbook 'percona'
    source 'replication.sql.erb'
    variables(replication_password: passwords.replication_password(server['replication']['username'], server['replication']['password']))
    owner 'root'
    group 'root'
    mode '0600'
    sensitive true
    only_if do
      (server['replication']['host'] != '' || server['role'].include?('source') || server['role'].include?('master')) && !::File.exist?(new_resource.replication_sql)
    end
  end

  execute 'mysql-set-replication' do
    command lazy {
      root_password = passwords.root_password(server['root_password']).to_s
      escaped = root_password.empty? ? '' : Shellwords.escape(root_password).prepend('-p')
      "/usr/bin/mysql #{escaped} < #{new_resource.replication_sql}"
    }
    action :nothing
    subscribes :run, "template[#{new_resource.replication_sql}]", :immediately
    sensitive true
  end
end

action :delete do
  file new_resource.replication_sql do
    action :delete
  end
end
