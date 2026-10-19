# frozen_string_literal: true

require 'json'
require 'securerandom'

module Percona
  module Cookbook
    module Helpers
      SUPPORTED_VERSIONS = %w(8.0 8.4).freeze

      def percona_version(version = new_resource.version)
        validate_percona_version!(version)

        version
      end

      def percona_repo_names(options = {})
        version = options.fetch(:version, new_resource.version)
        cluster = options.fetch(:cluster, false)
        validate_percona_version!(version)

        repos = {
          '8.0' => {
            true => %w(pxc-80),
            false => %w(ps-80),
          },
          '8.4' => {
            true => %w(pxc-84-lts),
            false => %w(ps-84-lts),
          },
        }

        repos.fetch(version).fetch(cluster)
      end

      def percona_client_package_names(options = {})
        version = options.fetch(:version, new_resource.version)
        cluster = options.fetch(:cluster, false)
        validate_percona_version!(version)

        if cluster
          %w(percona-xtradb-cluster-client)
        else
          %w(percona-server-client)
        end
      end

      def percona_devel_package(options = {})
        version = options.fetch(:version, new_resource.version)
        validate_percona_version!(version)

        return 'percona-server-devel' unless platform_family?('debian')

        version == '8.0' ? 'libperconaserverclient21-dev' : 'libperconaserverclient22-dev'
      end

      def percona_server_package
        'percona-server-server'
      end

      def percona_cluster_package
        'percona-xtradb-cluster-server'
      end

      def percona_backup_package(version = new_resource.version)
        validate_percona_version!(version)

        "percona-xtrabackup-#{version.tr('.', '')}"
      end

      def percona_jemalloc_package
        platform_family?('debian') ? 'libjemalloc2' : 'jemalloc'
      end

      def percona_jemalloc_lib
        platform_family?('debian') ? '/usr/lib/x86_64-linux-gnu/libjemalloc.so.2' : '/usr/lib64/libjemalloc.so.2'
      end

      def percona_default_encoding
        'utf8mb4'
      end

      def percona_default_collate
        'utf8mb4_0900_ai_ci'
      end

      def percona_default_socket
        platform_family?('debian') ? '/var/run/mysqld/mysqld.sock' : '/var/lib/mysql/mysql.sock'
      end

      def default_socket
        percona_default_socket
      end

      def percona_default_pidfile
        platform_family?('debian') ? '/var/run/mysqld/mysqld.pid' : '/var/lib/mysql/mysqld.pid'
      end

      def percona_default_includedir
        platform_family?('debian') ? '/etc/mysql/conf.d/' : ''
      end

      def percona_default_config_file
        platform_family?('debian') ? '/etc/mysql/my.cnf' : '/etc/my.cnf'
      end

      def percona_default_storage_engine
        platform_family?('debian') ? 'InnoDB' : 'innodb'
      end

      def percona_default_cluster_provider
        platform_family?('debian') ? '/usr/lib/libgalera_smm.so' : '/usr/lib64/libgalera_smm.so'
      end

      def percona_secure_random
        SecureRandom.hex
      end

      def default_server_config
        {
          'socket' => percona_default_socket,
          'default_storage_engine' => percona_default_storage_engine,
          'includedir' => percona_default_includedir,
          'pidfile' => percona_default_pidfile,
          'enable' => true,
          'package_action' => 'install',
          'role' => ['standalone'],
          'package' => [],
          'username' => 'mysql',
          'datadir' => '/var/lib/mysql',
          'logdir' => '/var/log/mysql',
          'tmpdir' => '/tmp',
          'slave_load_tmpdir' => '/tmp',
          'debian_username' => 'debian-sys-maint',
          'debian_password' => percona_secure_random,
          'root_password' => percona_secure_random,
          'jemalloc' => false,
          'nice' => 0,
          'open_files_limit' => 16_384,
          'hostname' => 'localhost',
          'basedir' => '/usr',
          'port' => 3306,
          'language' => '/usr/share/mysql/english',
          'character_set' => 'utf8',
          'collation' => 'utf8_unicode_ci',
          'skip_name_resolve' => false,
          'skip_external_locking' => true,
          'net_read_timeout' => 120,
          'connect_timeout' => 10,
          'wait_timeout' => 28_800,
          'old_passwords' => 0,
          'bind_address' => '127.0.0.1',
          'federated' => false,
          'report_host' => '',
          'key_buffer_size' => '16M',
          'max_allowed_packet' => '64M',
          'thread_stack' => '192K',
          'query_alloc_block_size' => '16K',
          'memlock' => false,
          'transaction_isolation' => 'REPEATABLE-READ',
          'tmp_table_size' => '64M',
          'max_heap_table_size' => '64M',
          'sort_buffer_size' => '8M',
          'join_buffer_size' => '8M',
          'thread_cache_size' => 16,
          'back_log' => -1,
          'max_connections' => 30,
          'max_connect_errors' => 9_999_999,
          'sql_modes' => [],
          'table_cache' => 8172,
          'table_definition_cache' => '-1',
          'group_concat_max_len' => 4096,
          'expand_fast_index_creation' => false,
          'read_rnd_buffer_size' => 262_144,
          'sysdate_is_now' => false,
          'sync_binlog' => 1,
          'slow_query_log' => 1,
          'slow_query_logdir' => '/var/log/mysql',
          'slow_query_log_file' => '/var/log/mysql/mysql-slow.log',
          'long_query_time' => 2,
          'log_queries_not_using_indexes' => 0,
          'server_id' => 1,
          'binlog_rows_query_log_events' => false,
          'binlog_do_db' => [],
          'binlog_ignore_db' => [],
          'expire_logs_days' => 10,
          'gtid_mode' => 'OFF',
          'enforce_gtid_consistency' => false,
          'max_binlog_size' => '100M',
          'binlog_cache_size' => '1M',
          'binlog_format' => 'ROW',
          'binlog_checksum' => 'CRC32',
          'log_bin' => 1,
          'log_bin_basename' => 'master-bin',
          'relay_log' => 'slave-relay-bin',
          'log_slave_updates' => false,
          'log_warnings' => false,
          'log_long_format' => false,
          'bulk_insert_buffer_size' => '64M',
          'sync_master_info' => false,
          'sync_relay_log' => false,
          'sync_relay_log_info' => false,
          'master_verify_checksum' => false,
          'slave_net_timeout' => 3600,
          'slave_sql_verify_checksum' => false,
          'myisam_recover_options' => 'BACKUP',
          'myisam_sort_buffer_size' => '128M',
          'myisam_max_sort_file_size' => '10G',
          'read_buffer_size' => '8M',
          'skip_innodb' => false,
          'innodb_buffer_pool_size' => '128M',
          'innodb_buffer_pool_instances' => 8,
          'innodb_buffer_pool_populate' => 0,
          'innodb_data_file_path' => 'ibdata1:10M:autoextend',
          'innodb_autoextend_increment' => '128M',
          'innodb_open_files' => 2000,
          'innodb_file_per_table' => true,
          'innodb_data_home_dir' => '',
          'innodb_thread_concurrency' => 16,
          'innodb_flush_log_at_trx_commit' => 1,
          'innodb_fast_shutdown' => false,
          'innodb_log_buffer_size' => '64M',
          'innodb_log_file_size' => '5M',
          'innodb_log_files_in_group' => 2,
          'innodb_max_dirty_pages_pct' => 80,
          'innodb_flush_method' => 'O_DIRECT',
          'innodb_lock_wait_timeout' => 120,
          'innodb_import_table_from_xtrabackup' => 0,
          'innodb_numa_interleave' => 0,
          'performance_schema' => false,
          'replication' => default_replication_config,
          'skip_syslog' => false,
        }
      end

      def default_replication_config
        {
          'read_only' => false,
          'host' => '',
          'username' => '',
          'password' => '',
          'port' => 3306,
          'ignore_db' => [],
          'ignore_table' => [],
          'ssl_enabled' => false,
          'suppress_1592' => false,
          'skip_slave_start' => false,
          'replication_sql' => '/etc/mysql/replication.sql',
          'slave_transaction_retries' => 10,
        }
      end

      def default_backup_config
        {
          'configure' => false,
          'username' => 'backup',
          'password' => percona_secure_random,
        }
      end

      def default_cluster_config
        {
          'binlog_format' => 'ROW',
          'wsrep_provider' => percona_default_cluster_provider,
          'wsrep_provider_options' => '',
          'wsrep_cluster_address' => '',
          'wsrep_slave_threads' => 2,
          'wsrep_cluster_name' => '',
          'wsrep_sst_method' => 'rsync',
          'wsrep_node_name' => '',
          'wsrep_notify_cmd' => '',
          'wsrep_sst_auth' => '',
          'wsrep_sst_receive_interface' => nil,
          'wsrep_sst_receive_port' => '4444',
          'innodb_locks_unsafe_for_binlog' => 1,
          'innodb_autoinc_lock_mode' => 2,
        }
      end

      def default_percona_config(version: '8.4', cluster_enabled: false)
        {
          'version' => version,
          'cluster_enabled' => cluster_enabled,
          'auto_restart' => true,
          'selinux_module_url' => '',
          'main_config_file' => percona_default_config_file,
          'main_config_template' => {
            'cookbook' => 'percona',
            'source' => {
              'default' => 'my.cnf.main.erb',
              'cluster' => 'my.cnf.cluster.erb',
            },
          },
          'encrypted_data_bag' => 'passwords',
          'encrypted_data_bag_secret_file' => '',
          'encrypted_data_bag_item_mysql' => 'mysql',
          'encrypted_data_bag_item_system' => 'system',
          'encrypted_data_bag_item_ssl_replication' => 'ssl_replication',
          'use_chef_vault' => false,
          'skip_passwords' => false,
          'skip_configure' => false,
          'server' => default_server_config,
          'backup' => default_backup_config,
          'cluster' => default_cluster_config,
          'conf' => {},
        }
      end

      def deep_merge(left, right)
        left.merge(right) do |_key, old_value, new_value|
          old_value.is_a?(Hash) && new_value.is_a?(Hash) ? deep_merge(old_value, new_value) : new_value
        end
      end

      def merged_percona_config(overrides = {}, version: '8.4', cluster_enabled: false)
        deep_merge(default_percona_config(version: version, cluster_enabled: cluster_enabled), stringify_keys(overrides))
      end

      def stringify_keys(value)
        case value
        when Hash
          value.each_with_object({}) { |(key, val), memo| memo[key.to_s] = stringify_keys(val) }
        when Array
          value.map { |item| stringify_keys(item) }
        else
          value
        end
      end

      def apply_legacy_template_config(config)
        node.default['percona'] = config
      end

      def validate_percona_version!(version)
        return if SUPPORTED_VERSIONS.include?(version)

        raise "Percona version #{version} is not supported. Supported versions are: #{SUPPORTED_VERSIONS.join(', ')}"
      end

      include Chef::Mixin::ShellOut

      def sql_command_string(query, database, ctrl, grep_for = nil)
        raw_query = query.is_a?(String) ? query : query.join(";\n")
        Chef::Log.debug("Control Hash: [#{ctrl.to_json}]\n")
        cmd = "/usr/bin/mysql -B -e \"#{raw_query}\""
        cmd << " --user=#{ctrl[:user]}" if ctrl && ctrl.key?(:user) && !ctrl[:user].nil?
        cmd << " -p'#{ctrl[:password]}'" if ctrl && ctrl.key?(:password) && !ctrl[:password].nil?
        cmd << " -h #{ctrl[:host]}" if ctrl && ctrl.key?(:host) && !ctrl[:host].nil? && ctrl[:host] != 'localhost'
        cmd << " -P #{ctrl[:port]}" if ctrl && ctrl.key?(:port) && !ctrl[:port].nil? && ctrl[:host] != 'localhost'
        cmd << " -S #{ctrl[:socket]}" if ctrl && ctrl.key?(:socket) && !ctrl[:socket].nil?
        cmd << " #{database}" unless database.nil?
        cmd << " | grep #{grep_for}" if grep_for
        Chef::Log.debug("Executing this command: [#{cmd}]\n")
        cmd
      end

      def execute_sql(query, db_name, ctrl)
        cmd = shell_out(sql_command_string(query, db_name, ctrl), user: 'root')
        if cmd.exitstatus != 0
          Chef::Log.fatal("mysql failed executing this SQL statement:\n#{query}")
          Chef::Log.fatal(cmd.stderr)
          raise 'SQL ERROR'
        end
        cmd.stdout
      end

      def execute_sql_exitstatus(query, ctrl)
        shell_out(sql_command_string(query, nil, ctrl), user: 'root').exitstatus
      end

      def parse_one_row(row, titles)
        row.split("\t").each_with_index.with_object({}) do |(column, index), return_hash|
          return_hash[titles[index]] = column
        end
      end

      def parse_mysql_batch_result(mysql_batch_result)
        rows = mysql_batch_result.split("\n")
        titles = rows.shift.to_s.split("\t")
        rows.map { |row| parse_one_row(row, titles) }
      end
    end
  end
end
