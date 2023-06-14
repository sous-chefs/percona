#
# Cookbook:: percona
# Attributes:: default
#

# include the percona_secure_random method
::Chef::Node.include ::Percona::Cookbook::Helpers

default['percona']['version'] = '8.0'

# Always restart percona on configuration changes
default['percona']['auto_restart'] = true

# SELinux module URL
# If interested, use "https://github.com/gguillen/selinux_percona-pxc-56-cluster/raw/master/percona-pxc-56-cluster.pp"
default['percona']['selinux_module_url'] = ''

case node['platform_family']
when 'debian'
  default['percona']['server']['socket'] = '/var/run/mysqld/mysqld.sock'
  default['percona']['server']['default_storage_engine'] = 'InnoDB'
  default['percona']['server']['includedir'] = '/etc/mysql/conf.d/'
  default['percona']['server']['pidfile'] = '/var/run/mysqld/mysqld.pid'
when 'rhel'
  default['percona']['server']['socket'] = '/var/lib/mysql/mysql.sock'
  default['percona']['server']['default_storage_engine'] = 'innodb'
  default['percona']['server']['includedir'] = ''
  default['percona']['server']['pidfile'] = '/var/lib/mysql/mysqld.pid'
end

# Cookbook Settings
default['percona']['main_config_file'] = value_for_platform_family(
  'debian' => '/etc/mysql/my.cnf',
  'rhel' => '/etc/my.cnf'
)
default['percona']['main_config_template']['cookbook'] = 'percona'
default['percona']['main_config_template']['source']['default'] = 'my.cnf.main.erb'
default['percona']['main_config_template']['source']['cluster'] = 'my.cnf.cluster.erb'
default['percona']['encrypted_data_bag'] = 'passwords'
default['percona']['encrypted_data_bag_secret_file'] = ''
default['percona']['encrypted_data_bag_item_mysql'] = 'mysql'
default['percona']['encrypted_data_bag_item_system'] = 'system'
default['percona']['encrypted_data_bag_item_ssl_replication'] = 'ssl_replication'
default['percona']['use_chef_vault'] = false
default['percona']['skip_passwords'] = false
default['percona']['skip_configure'] = false

# Start percona server on boot
default['percona']['server']['enable'] = true

# install vs. upgrade packages
default['percona']['server']['package_action'] = 'install'

# Basic Settings
default['percona']['server']['role'] = ['standalone']
default['percona']['server']['package'] = []
default['percona']['server']['username'] = 'mysql'
default['percona']['server']['datadir'] = '/var/lib/mysql'
default['percona']['server']['logdir'] = '/var/log/mysql'
default['percona']['server']['tmpdir'] = '/tmp'
default['percona']['server']['slave_load_tmpdir'] = '/tmp'
default['percona']['server']['debian_username'] = 'debian-sys-maint'
default['percona']['server']['jemalloc'] = false
default['percona']['server']['nice'] = 0
default['percona']['server']['open_files_limit'] = 16_384
default['percona']['server']['hostname'] = 'localhost'
default['percona']['server']['basedir'] = '/usr'
default['percona']['server']['port'] = 3306
default['percona']['server']['language'] = '/usr/share/mysql/english'
default['percona']['server']['character_set'] = 'utf8'
default['percona']['server']['collation'] = 'utf8_unicode_ci'
default['percona']['server']['skip_name_resolve'] = false
default['percona']['server']['skip_external_locking'] = true
default['percona']['server']['net_read_timeout'] = 120
default['percona']['server']['connect_timeout'] = 10
default['percona']['server']['wait_timeout'] = 28_800
default['percona']['server']['old_passwords'] = 0
default['percona']['server']['bind_address'] = '127.0.0.1'
default['percona']['server']['federated'] = false
default['percona']['server']['report_host'] = ''

%w(debian_password root_password).each do |attribute|
  next if attribute?(node['percona']['server'][attribute])
  default['percona']['server'][attribute] = percona_secure_random
end

# Fine Tuning
default['percona']['server']['key_buffer_size'] = '16M'
default['percona']['server']['max_allowed_packet'] = '64M'
default['percona']['server']['thread_stack'] = '192K'
default['percona']['server']['query_alloc_block_size'] = '16K'
default['percona']['server']['memlock'] = false
default['percona']['server']['transaction_isolation'] = 'REPEATABLE-READ'
default['percona']['server']['tmp_table_size'] = '64M'
default['percona']['server']['max_heap_table_size'] = '64M'
default['percona']['server']['sort_buffer_size'] = '8M'
default['percona']['server']['join_buffer_size'] = '8M'
default['percona']['server']['thread_cache_size'] = 16
default['percona']['server']['back_log'] = -1 # <5.6.6, use 50
default['percona']['server']['max_connections'] = 30
default['percona']['server']['max_connect_errors'] = 9_999_999
default['percona']['server']['sql_modes'] = []
default['percona']['server']['table_cache'] = 8172
default['percona']['server']['table_definition_cache'] = '-1' # <5.6, use 4096
default['percona']['server']['group_concat_max_len'] = 4096
default['percona']['server']['expand_fast_index_creation'] = false
default['percona']['server']['read_rnd_buffer_size'] = 262_144
default['percona']['server']['sysdate_is_now'] = false

# Query Cache Configuration
default['percona']['server']['query_cache_size'] = '64M'
default['percona']['server']['query_cache_limit'] = '2M'
default['percona']['server']['query_cache_type'] = '1'

# Logging and Replication
default['percona']['server']['sync_binlog'] = (node['percona']['server']['role'] == 'cluster' ? 0 : 1)
default['percona']['server']['slow_query_log'] = 1
default['percona']['server']['slow_query_logdir'] = '/var/log/mysql'
default['percona']['server']['slow_query_log_file'] = "#{node['percona']['server']['slow_query_logdir']}/mysql-slow.log"
default['percona']['server']['long_query_time'] = 2
default['percona']['server']['log_queries_not_using_indexes'] = 0
default['percona']['server']['server_id'] = 1
default['percona']['server']['binlog_rows_query_log_events'] = false
default['percona']['server']['binlog_do_db'] = []
default['percona']['server']['binlog_ignore_db'] = []
default['percona']['server']['expire_logs_days'] = 10
default['percona']['server']['gtid_mode'] = 'OFF'
default['percona']['server']['enforce_gtid_consistency'] = false
default['percona']['server']['max_binlog_size'] = '100M'
default['percona']['server']['binlog_cache_size'] = '1M'
default['percona']['server']['binlog_format'] = 'ROW' # Alt. MIXED
default['percona']['server']['binlog_checksum'] = 'CRC32'
default['percona']['server']['log_bin'] = 1 # enable/disable bin log
default['percona']['server']['log_bin_basename'] = 'master-bin' # 5.6~> default: datadir + '/' + hostname + '-bin'
default['percona']['server']['relay_log'] = 'slave-relay-bin'
default['percona']['server']['log_slave_updates'] = false
default['percona']['server']['log_warnings'] = node['percona']['version'].to_i < 8
default['percona']['server']['log_long_format'] = false
default['percona']['server']['bulk_insert_buffer_size'] = '64M'
default['percona']['server']['sync_master_info'] = false
default['percona']['server']['sync_relay_log'] = false
default['percona']['server']['sync_relay_log_info'] = false
default['percona']['server']['master_verify_checksum'] = false
default['percona']['server']['slave_net_timeout'] = 3600
default['percona']['server']['slave_sql_verify_checksum'] = false

# MyISAM Specific
default['percona']['server']['myisam_recover_options'] = 'BACKUP'
default['percona']['server']['myisam_sort_buffer_size'] = '128M'
default['percona']['server']['myisam_max_sort_file_size'] = '10G'
default['percona']['server']['myisam_repair_threads'] = 1
default['percona']['server']['read_buffer_size'] = '8M'

# InnoDB Specific
default['percona']['server']['skip_innodb'] = false
default['percona']['server']['innodb_additional_mem_pool_size'] = '32M'
default['percona']['server']['innodb_buffer_pool_size'] = '128M'
default['percona']['server']['innodb_buffer_pool_instances'] = 8
default['percona']['server']['innodb_buffer_pool_populate'] = 0 # Introduced: MariaDB 5.5 / XtraDB 5.5.28-29.1
default['percona']['server']['innodb_data_file_path'] = 'ibdata1:10M:autoextend'
default['percona']['server']['innodb_autoextend_increment'] = '128M'
default['percona']['server']['innodb_open_files'] = 2000
default['percona']['server']['innodb_file_per_table'] = true
default['percona']['server']['innodb_file_format'] = 'Antelope'
default['percona']['server']['innodb_data_home_dir'] = ''
default['percona']['server']['innodb_thread_concurrency'] = 16
default['percona']['server']['innodb_flush_log_at_trx_commit'] = 1
default['percona']['server']['innodb_fast_shutdown'] = false
default['percona']['server']['innodb_log_buffer_size'] = '64M'
default['percona']['server']['innodb_log_file_size'] = '5M'
default['percona']['server']['innodb_log_files_in_group'] = 2
default['percona']['server']['innodb_max_dirty_pages_pct'] = 80
default['percona']['server']['innodb_flush_method'] = 'O_DIRECT'
default['percona']['server']['innodb_lock_wait_timeout'] = 120
default['percona']['server']['innodb_import_table_from_xtrabackup'] = 0
default['percona']['server']['innodb_numa_interleave'] = 0

# Performance Schema
default['percona']['server']['performance_schema'] = false

# Replication Settings
default['percona']['server']['replication']['read_only'] = false
default['percona']['server']['replication']['host'] = ''
default['percona']['server']['replication']['username'] = ''
default['percona']['server']['replication']['password'] = ''
default['percona']['server']['replication']['port'] = 3306
default['percona']['server']['replication']['ignore_db'] = []
default['percona']['server']['replication']['ignore_table'] = []
default['percona']['server']['replication']['ssl_enabled'] = false
default['percona']['server']['replication']['suppress_1592'] = false
default['percona']['server']['replication']['skip_slave_start'] = false
default['percona']['server']['replication']['replication_sql'] = '/etc/mysql/replication.sql'
default['percona']['server']['replication']['slave_transaction_retries'] = 10

# Mysqld_safe
default['percona']['server']['skip_syslog'] = false

# XtraBackup Settings
default['percona']['backup']['configure'] = false
default['percona']['backup']['username'] = 'backup'
unless attribute?(node['percona']['backup']['password'])
  default['percona']['backup']['password'] = percona_secure_random
end

# XtraDB Cluster Settings
default['percona']['cluster']['binlog_format'] = 'ROW'
default['percona']['cluster']['wsrep_provider'] = value_for_platform_family(
  'debian' => '/usr/lib/libgalera_smm.so',
  'rhel' => '/usr/lib64/libgalera_smm.so'
)
default['percona']['cluster']['wsrep_provider_options'] = ''
default['percona']['cluster']['wsrep_cluster_address'] = ''
default['percona']['cluster']['wsrep_slave_threads'] = 2
default['percona']['cluster']['wsrep_cluster_name'] = ''
default['percona']['cluster']['wsrep_sst_method'] = 'rsync'
default['percona']['cluster']['wsrep_node_name'] = ''
default['percona']['cluster']['wsrep_notify_cmd'] = ''
default['percona']['cluster']['wsrep_sst_auth'] = ''

# These both are used to build wsrep_sst_receive_address
default['percona']['cluster']['wsrep_sst_receive_interface'] = nil # Works like node["percona"]["server"]["bind_to"]
default['percona']['cluster']['wsrep_sst_receive_port'] = '4444'

default['percona']['cluster']['innodb_locks_unsafe_for_binlog'] = 1
default['percona']['cluster']['innodb_autoinc_lock_mode'] = 2
