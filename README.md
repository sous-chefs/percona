# DESCRIPTION

Installs the [Percona MySQL](http://www.percona.com/software/percona-server) client and/or server components. Optionally installs the [XtraBackup](http://www.percona.com/software/percona-xtrabackup/) hot backup software.


# REQUIREMENTS

## Supported Platforms

The following platforms are supported by this cookbook, meaning that the recipes run on these platforms without error:

* Ubuntu
* Debian

# RECIPES

* `percona` - The default recipe. This sets up the apt repository and install common packages.
* `percona::client` - Installs the Percona MySQL client libraries.
* `percona::server` - Installs and configures the Percona MySQL server daemon.
* `percona::backup` - Installs and configures the Percona XtraBackup hot backup software.
* `percona::access_grants` - Used internally to grant permissions for recipes.

# USAGE

This cookbook installs the Percona MySQL components if not present, and pulls updates if they are installed on the system.

# ATTRIBUTES

* `node[:percona][:server][:role]` default: "standalone", options: "standalone", "master", "slave"
* `node[:percona][:keyserver]` default: "keys.gnupg.net"

## Basic Settings

* `node[:percona][:server][:username]`                        default: "mysql"
* `node[:percona][:server][:datadir]`                         default: "/var/lib/mysql"
* `node[:percona][:server][:includedir]`                      default: "/etc/mysql/conf.d/"
* `node[:percona][:server][:tmpdir]`                          default: "/tmp"
* `node[:percona][:server][:root_password]`                   default: "123-changeme"
* `node[:percona][:server][:debian_username]`                 default: "debian-sys-maint"
* `node[:percona][:server][:debian_password]`                 default: "123-changeme"
* `node[:percona][:server][:socket]`                          default: "/var/run/mysqld/mysqld.sock"
* `node[:percona][:server][:nice]`                            default: 0
* `node[:percona][:server][:open_files_limit]`                default: 16384
* `node[:percona][:server][:hostname]`                        default: "localhost"
* `node[:percona][:server][:basedir]`                         default: "/usr"
* `node[:percona][:server][:pidfile]`                         default: "/var/run/mysqld/mysqld.pid"
* `node[:percona][:server][:port]`                            default: 3306
* `node[:percona][:server][:language]`                        default: "/usr/share/mysql/english"
* `node[:percona][:server][:skip_external_locking]`           default: true
* `node[:percona][:server][:net_read_timeout]`                default: 120
* `node[:percona][:server][:old_passwords]`                   default: 1
* `node[:percona][:server][:bind_address]`                    default: "127.0.0.1"

## Fine Tuning

* `node[:percona][:server][:key_buffer]`                      default: "16M"
* `node[:percona][:server][:max_allowed_packet]`              default: "64M"
* `node[:percona][:server][:thread_stack]`                    default: "192K"
* `node[:percona][:server][:query_alloc_block_size]`          default: "16K"
* `node[:percona][:server][:memlock]`                         default: false
* `node[:percona][:server][:transaction_isolation]`           default: "REPEATABLE-READ"
* `node[:percona][:server][:tmp_table_size]`                  default: "64M"
* `node[:percona][:server][:default_table_type]`              default: "InnoDB"
* `node[:percona][:server][:max_heap_table_size]`             default: "64M"
* `node[:percona][:server][:sort_buffer_size]`                default: "8M"
* `node[:percona][:server][:join_buffer_size]`                default: "8M"
* `node[:percona][:server][:thread_cache_size]`               default: 16
* `node[:percona][:server][:myisam_recover]`                  default: "BACKUP"
* `node[:percona][:server][:back_log]`                        default: 50
* `node[:percona][:server][:max_connections]`                 default: 30
* `node[:percona][:server][:max_connect_errors]`              default: 9999999
* `node[:percona][:server][:table_cache]`                     default: 8192
* `node[:percona][:server][:bulk_insert_buffer_size]`         default: "64M"

## Query Cache Configuration

* `node[:percona][:server][:query_cache_size]`                default: "64M"
* `node[:percona][:server][:query_cache_limit]`               default: "2M"

## Logging and Replication

* `node[:percona][:server][:sync_binlog]`                     default: 1
* `node[:percona][:server][:slow_query_log]`                  default: "/var/log/mysql/mysql-slow.log"
* `node[:percona][:server][:long_query_time]`                 default: 2
* `node[:percona][:server][:server_id]`                       default: 1
* `node[:percona][:server][:binlog_do_db]`                    default: ""
* `node[:percona][:server][:expire_logs_days]`                default: 10
* `node[:percona][:server][:max_binlog_size]`                 default: "100M"
* `node[:percona][:server][:binlog_cache_size]`               default: "1M"
* `node[:percona][:server][:log_bin]`                         default: ""
* `node[:percona][:server][:log_slave_updates]`               default: false
* `node[:percona][:server][:log_warnings]`                    default: true
* `node[:percona][:server][:log_long_format]`                 default: false

### Replication options

* `node[:percona][:server][:replication][:read_only]`         default: false
* `node[:percona][:server][:replication][:host]`              default: ""
* `node[:percona][:server][:replication][:username]`          default: ""
* `node[:percona][:server][:replication][:password]`          default: ""
* `node[:percona][:server][:replication][:port]`              default: 3306

## MyISAM Specific options

* `node[:percona][:server][:myisam_sort_buffer_size]`         default: "128M"
* `node[:percona][:server][:myisam_max_sort_file_size]`       default: "10G"
* `node[:percona][:server][:myisam_repair_threads]`           default: 1
* `node[:percona][:server][:myisam_recover]`                  default: "BACKUP"

## BDB Specific options

* `node[:percona][:server][:skip_bdb]`                        default: true

## InnoDB Specific options

* `node[:percona][:server][:skip_innodb]`                     default: false
* `node[:percona][:server][:innodb_additional_mem_pool_size]` default: "32M"
* `node[:percona][:server][:innodb_buffer_pool_size]`         default: "6G"
* `node[:percona][:server][:innodb_data_file_path]`           default: "ibdata1:1G:autoextend"
* `node[:percona][:server][:innodb_file_per_table]`           default: true
* `node[:percona][:server][:innodb_data_home_dir]`            default: ""
* `node[:percona][:server][:innodb_thread_concurrency]`       default: 16
* `node[:percona][:server][:innodb_flush_log_at_trx_commit]`  default: 1
* `node[:percona][:server][:innodb_fast_shutdown]`            default: false
* `node[:percona][:server][:innodb_log_buffer_size]`          default: "8M"
* `node[:percona][:server][:innodb_log_file_size]`            default: "1G"
* `node[:percona][:server][:innodb_log_files_in_group]`       default: 2
* `node[:percona][:server][:innodb_max_dirty_pages_pct]`      default: 80
* `node[:percona][:server][:innodb_flush_method]`             default: "O_DIRECT"
* `node[:percona][:server][:innodb_lock_wait_timeout]`        default: 120

## XtraBackup Specific options

* `node[:percona][:backup][:configure]`                       default: false
* `node[:percona][:backup][:username]`                        default: "backup"
* `node[:percona][:backup][:password]`                        default: "123-changeme"


# LICENSE and AUTHOR:

Author:: Phil Cohen (<github@phlippers.net>)

Copyright:: 2011-2012, Phil Cohen

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
