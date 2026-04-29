# frozen_string_literal: true

property :version, String, default: '8.4'
property :server_config, Hash, default: {}
property :backup_config, Hash, default: {}
property :cluster_config, Hash, default: {}
property :extra_config, Hash, default: {}
property :main_config_file, [String, nil], default: nil
property :auto_restart, [true, false], default: true
property :skip_passwords, [true, false], default: false
property :encrypted_data_bag, String, default: 'passwords'
property :encrypted_data_bag_secret_file, String, default: ''
property :encrypted_data_bag_item_mysql, String, default: 'mysql'
property :encrypted_data_bag_item_system, String, default: 'system'
property :encrypted_data_bag_item_ssl_replication, String, default: 'ssl_replication'
property :use_chef_vault, [true, false], default: false
