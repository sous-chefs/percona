# frozen_string_literal: true

provides :percona_backup
unified_mode true

use '_partial/_repository'
use '_partial/_config'

property :package_action, Symbol, default: :install, equal_to: %i(install upgrade remove purge)
property :configure_repository, [true, false], default: true
property :configure_grants, [true, false], default: true

action_class do
  include Percona::Cookbook::Helpers
end

action :install do
  percona_repository 'percona' do
    version new_resource.version
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

  package 'xtrabackup' do
    package_name percona_backup_package(new_resource.version)
    action new_resource.package_action
  end

  percona_access_grants 'backup grants' do
    version new_resource.version
    server_config new_resource.server_config
    backup_config deep_merge(new_resource.backup_config, 'configure' => true)
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
  package 'xtrabackup' do
    package_name percona_backup_package(new_resource.version)
    action :remove
  end
end
