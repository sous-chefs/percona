# frozen_string_literal: true

provides :percona_server
unified_mode true

use '_partial/_repository'
use '_partial/_config'

property :packages, Array, default: []
property :package_action, Symbol, default: :install, equal_to: %i(install upgrade remove purge)
property :configure_repository, [true, false], default: true
property :configure_server, [true, false], default: true
property :configure_grants, [true, false], default: true
property :configure_replication, [true, false], default: true
property :install_client, [true, false], default: true
property :install_devel_package, [true, false], default: false
property :systemd_open_files_limit, [Integer, nil], default: nil

action_class do
  include Percona::Cookbook::Helpers

  def reload_systemd_on_limit_change
    execute 'reload systemd for Percona limits' do
      command %w(systemctl daemon-reload)
      action :nothing
    end
  end
end

action :install do
  effective_server_config = merged_percona_config({ 'server' => new_resource.server_config }, version: new_resource.version)['server']

  percona_repository 'percona' do
    version new_resource.version
    cluster false
    apt_key new_resource.apt_key
    apt_uri new_resource.apt_uri
    yum_description new_resource.yum_description
    yum_baseurl new_resource.yum_baseurl
    yum_gpgkey new_resource.yum_gpgkey
    yum_gpgcheck new_resource.yum_gpgcheck
    yum_sslverify new_resource.yum_sslverify
    action :create
    only_if { new_resource.configure_repository }
  end

  percona_client 'percona' do
    version new_resource.version
    install_devel_package new_resource.install_devel_package
    configure_repository false
    action :install
    only_if { new_resource.install_client }
  end

  package 'percona server package' do
    package_name(new_resource.packages.empty? ? percona_server_package : new_resource.packages)
    action new_resource.package_action
  end

  if platform_family?('rhel', 'fedora', 'amazon')
    reload_systemd_on_limit_change

    directory '/etc/systemd/system/mysqld.service.d' do
      owner 'root'
      group 'root'
      mode '0755'
    end

    open_files_limit = new_resource.systemd_open_files_limit || effective_server_config['open_files_limit']
    file '/etc/systemd/system/mysqld.service.d/limits.conf' do
      content "[Service]\nLimitNOFILE=#{open_files_limit}\n"
      owner 'root'
      group 'root'
      mode '0644'
      notifies :run, 'execute[reload systemd for Percona limits]', :immediately
    end
  end

  percona_server_config 'percona' do
    version new_resource.version
    server_config new_resource.server_config
    backup_config new_resource.backup_config
    cluster_config new_resource.cluster_config
    extra_config new_resource.extra_config
    main_config_file(new_resource.main_config_file || percona_default_config_file)
    auto_restart new_resource.auto_restart
    skip_passwords new_resource.skip_passwords
    encrypted_data_bag new_resource.encrypted_data_bag
    encrypted_data_bag_secret_file new_resource.encrypted_data_bag_secret_file
    encrypted_data_bag_item_mysql new_resource.encrypted_data_bag_item_mysql
    encrypted_data_bag_item_system new_resource.encrypted_data_bag_item_system
    encrypted_data_bag_item_ssl_replication new_resource.encrypted_data_bag_item_ssl_replication
    use_chef_vault new_resource.use_chef_vault
    action :create
    only_if { new_resource.configure_server }
  end

  percona_access_grants 'percona' do
    version new_resource.version
    server_config new_resource.server_config
    backup_config new_resource.backup_config
    extra_config new_resource.extra_config
    main_config_file(new_resource.main_config_file || percona_default_config_file)
    encrypted_data_bag new_resource.encrypted_data_bag
    encrypted_data_bag_secret_file new_resource.encrypted_data_bag_secret_file
    encrypted_data_bag_item_mysql new_resource.encrypted_data_bag_item_mysql
    encrypted_data_bag_item_system new_resource.encrypted_data_bag_item_system
    use_chef_vault new_resource.use_chef_vault
    action :create
    only_if { new_resource.configure_grants && !new_resource.skip_passwords }
  end

  percona_replication 'percona' do
    version new_resource.version
    server_config new_resource.server_config
    backup_config new_resource.backup_config
    cluster_config new_resource.cluster_config
    extra_config new_resource.extra_config
    main_config_file(new_resource.main_config_file || percona_default_config_file)
    encrypted_data_bag new_resource.encrypted_data_bag
    encrypted_data_bag_secret_file new_resource.encrypted_data_bag_secret_file
    encrypted_data_bag_item_mysql new_resource.encrypted_data_bag_item_mysql
    encrypted_data_bag_item_system new_resource.encrypted_data_bag_item_system
    use_chef_vault new_resource.use_chef_vault
    action :create
    only_if { new_resource.configure_replication && !new_resource.skip_passwords }
  end
end

action :remove do
  if platform_family?('rhel', 'fedora', 'amazon')
    reload_systemd_on_limit_change

    file '/etc/systemd/system/mysqld.service.d/limits.conf' do
      action :delete
      notifies :run, 'execute[reload systemd for Percona limits]', :immediately
    end
  end

  package 'percona server package' do
    package_name(new_resource.packages.empty? ? percona_server_package : new_resource.packages)
    action :remove
  end
end
