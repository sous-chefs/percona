# frozen_string_literal: true

provides :percona_cluster
unified_mode true

use '_partial/_repository'
use '_partial/_config'

property :packages, Array, default: []
property :package_action, Symbol, default: :install, equal_to: %i(install upgrade remove purge)
property :configure_repository, [true, false], default: true
property :configure_server, [true, false], default: true
property :configure_grants, [true, false], default: true

action_class do
  include Percona::Cookbook::Helpers
end

action :install do
  effective_cluster_config = deep_merge(default_cluster_config, stringify_keys(new_resource.cluster_config))
  effective_server_config = deep_merge(default_server_config, stringify_keys(new_resource.server_config))

  if effective_cluster_config['wsrep_sst_receive_interface']
    ip = Percona::ConfigHelper.bind_to(node, effective_cluster_config['wsrep_sst_receive_interface'])
    effective_cluster_config['wsrep_sst_receive_address'] = "#{ip}:#{effective_cluster_config['wsrep_sst_receive_port']}" if ip
  end

  percona_repository 'percona cluster' do
    version new_resource.version
    cluster true
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

  percona_client 'percona cluster' do
    version new_resource.version
    cluster true
    configure_repository false
    action :install
  end

  package 'percona cluster package' do
    package_name(new_resource.packages.empty? ? percona_cluster_package : new_resource.packages)
    action new_resource.package_action
  end

  percona_server_config 'percona cluster' do
    version new_resource.version
    cluster true
    server_config deep_merge(effective_server_config, 'role' => Array(effective_server_config['role']) | ['cluster'])
    backup_config new_resource.backup_config
    cluster_config effective_cluster_config
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

  percona_access_grants 'percona cluster' do
    version new_resource.version
    server_config effective_server_config
    backup_config new_resource.backup_config
    cluster_config effective_cluster_config
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
end

action :remove do
  package 'percona cluster package' do
    package_name(new_resource.packages.empty? ? percona_cluster_package : new_resource.packages)
    action :remove
  end
end
