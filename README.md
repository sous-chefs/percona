# chef-percona

## Description

Installs the [Percona MySQL](http://www.percona.com/software/percona-server) client and/or server components. Optionally installs:

* [XtraBackup](http://www.percona.com/software/percona-xtrabackup/) hot backup software
* [Percona Toolkit](http://www.percona.com/software/percona-toolkit/) advanced command-line tools
* [XtraDB Cluster](http://www.percona.com/software/percona-xtradb-cluster/) high availability and high scalability solution for MySQL


## Requirements

### Supported Platforms

The following platforms are supported by this cookbook, meaning that the recipes run on these platforms without error:

* Ubuntu
* Debian

### Cookbooks

* [apt](http://community.opscode.com/cookbooks/apt) Opscode LWRP Cookbook

## Recipes

* `percona` - The default recipe. This sets up the apt repository and install common packages.
* `percona::client` - Installs the Percona MySQL client libraries.
* `percona::server` - Installs and configures the Percona MySQL server daemon.
* `percona::backup` - Installs and configures the Percona XtraBackup hot backup software.
* `percona::toolkit` - Installs the Percona Toolkit software
* `percona::cluster` - Installs the Percona XtraDB Cluster server components
* `percona::replication` - Used internally to grant permissions for replication.
* `percona::access_grants` - Used internally to grant permissions for recipes.


## Usage

This cookbook installs the Percona MySQL components if not present, and pulls updates if they are installed on the system.

### Encrypted Passwords

This cookbook supports [Encrypted Data Bags](http://wiki.opscode.com/display/chef/Encrypted+Data+Bags).

To use encrypted passwords, you must create an encrypted data bag. This cookbook assumes a data bag named `passwords`, but you can override the name using the `node[:percona][:encrypted_data_bag]` attribute. 

This cookbook expects a `mysql` item  and a `system` item.

#### mysql item

The mysql item should contain entries for root, backup, and replicaiton. If no value is found, the cookbook will fall back to the default non-encrypted password.

#### system item

The "system" item should contain an entry for the debian system user as specified in the `node[:percona][:server][:debian_username]` attribute. If no such entry is found, the cookbook will fall back to the default non-encrypted password.

Example: "passwords" data bag - this example assumes that `node[:percona][:server][:debian_username] = spud`

```javascript
{
  "mysql" :
  {
    "root" : "trywgFA6R70NO28PNhMpGhEvKBZuxouemnbnAUQsUyo=\n"
    "backup" : "eqoiudfj098389fjadfkadf=\n"
    "replication" : "qwo0fj0213fm9020fm2023fjsld=\n"
  },
  "system" :
  {
    "spud" : "dwoifm2340f024jfadgfu243hf2=\n"
  }
}
```

Above shows the encrypted password in the data bag. Check out the `encrypted_data_bag_secret` setting in `knife.rb` to setup your data bag secret during bootstrapping.

## Attributes

```ruby
# Cookbook Settings
default["percona"]["keyserver"]                                 = "keys.gnupg.net"
default["percona"]["encrypted_data_bag"]                        = "passwords"

# Basic Settings
default["percona"]["server"]["role"]                            = "standalone"
default["percona"]["server"]["username"]                        = "mysql"
default["percona"]["server"]["datadir"]                         = "/var/lib/mysql"
default["percona"]["server"]["includedir"]                      = "/etc/mysql/conf.d/"
default["percona"]["server"]["tmpdir"]                          = "/tmp"
default["percona"]["server"]["root_password"]                   = "123-changeme"
default["percona"]["server"]["debian_username"]                 = "debian-sys-maint"
default["percona"]["server"]["debian_password"]                 = "123-changeme"
default["percona"]["server"]["socket"]                          = "/var/run/mysqld/mysqld.sock"
default["percona"]["server"]["nice"]                            = 0
default["percona"]["server"]["open_files_limit"]                = 16384
default["percona"]["server"]["hostname"]                        = "localhost"
default["percona"]["server"]["basedir"]                         = "/usr"
default["percona"]["server"]["pidfile"]                         = "/var/run/mysqld/mysqld.pid"
default["percona"]["server"]["port"]                            = 3306
default["percona"]["server"]["language"]                        = "/usr/share/mysql/english"
default["percona"]["server"]["skip_external_locking"]           = true
default["percona"]["server"]["net_read_timeout"]                = 120
default["percona"]["server"]["old_passwords"]                   = 1
default["percona"]["server"]["bind_address"]                    = "127.0.0.1"

# Fine Tuning
default["percona"]["server"]["key_buffer"]                      = "16M"
default["percona"]["server"]["max_allowed_packet"]              = "64M"
default["percona"]["server"]["thread_stack"]                    = "192K"
default["percona"]["server"]["query_alloc_block_size"]          = "16K"
default["percona"]["server"]["memlock"]                         = false
default["percona"]["server"]["transaction_isolation"]           = "REPEATABLE-READ"
default["percona"]["server"]["tmp_table_size"]                  = "64M"
default["percona"]["server"]["default_storage_engine"]          = "InnoDB"
default["percona"]["server"]["max_heap_table_size"]             = "64M"
default["percona"]["server"]["sort_buffer_size"]                = "8M"
default["percona"]["server"]["join_buffer_size"]                = "8M"
default["percona"]["server"]["thread_cache_size"]               = 16
default["percona"]["server"]["back_log"]                        = 50
default["percona"]["server"]["max_connections"]                 = 30
default["percona"]["server"]["max_connect_errors"]              = 9999999
default["percona"]["server"]["table_cache"]                     = 8192

# Query Cache Configuration
default["percona"]["server"]["query_cache_size"]                = "64M"
default["percona"]["server"]["query_cache_limit"]               = "2M"

# Logging and Replication
default["percona"]["server"]["sync_binlog"]                     = 1
default["percona"]["server"]["slow_query_log"]                  = "/var/log/mysql/mysql-slow.log"
default["percona"]["server"]["long_query_time"]                 = 2
default["percona"]["server"]["server_id"]                       = 1
default["percona"]["server"]["binlog_do_db"]                    = []
default["percona"]["server"]["expire_logs_days"]                = 10
default["percona"]["server"]["max_binlog_size"]                 = "100M"
default["percona"]["server"]["binlog_cache_size"]               = "1M"
default["percona"]["server"]["log_bin"]                         = "master-bin"
default["percona"]["server"]["relay_log"]                       = "slave-relay-bin"
default["percona"]["server"]["log_slave_updates"]               = false
default["percona"]["server"]["log_warnings"]                    = true
default["percona"]["server"]["log_long_format"]                 = false
default["percona"]["server"]["bulk_insert_buffer_size"]         = "64M"

# MyISAM Specific
default["percona"]["server"]["myisam_recover"]                  = "BACKUP"
default["percona"]["server"]["myisam_sort_buffer_size"]         = "128M"
default["percona"]["server"]["myisam_max_sort_file_size"]       = "10G"
default["percona"]["server"]["myisam_repair_threads"]           = 1

# InnoDB Specific
default["percona"]["server"]["skip_innodb"]                     = false
default["percona"]["server"]["innodb_additional_mem_pool_size"] = "32M"
default["percona"]["server"]["innodb_buffer_pool_size"]         = "128M"
default["percona"]["server"]["innodb_data_file_path"]           = "ibdata1:10M:autoextend"
default["percona"]["server"]["innodb_file_per_table"]           = true
default["percona"]["server"]["innodb_data_home_dir"]            = ""
default["percona"]["server"]["innodb_thread_concurrency"]       = 16
default["percona"]["server"]["innodb_flush_log_at_trx_commit"]  = 1
default["percona"]["server"]["innodb_fast_shutdown"]            = false
default["percona"]["server"]["innodb_log_buffer_size"]          = "64M"
default["percona"]["server"]["innodb_log_file_size"]            = "5M"
default["percona"]["server"]["innodb_log_files_in_group"]       = 2
default["percona"]["server"]["innodb_max_dirty_pages_pct"]      = 80
default["percona"]["server"]["innodb_flush_method"]             = "O_DIRECT"
default["percona"]["server"]["innodb_lock_wait_timeout"]        = 120

# Replication Settings
default["percona"]["server"]["replication"]["read_only"]        = false
default["percona"]["server"]["replication"]["host"]             = ""
default["percona"]["server"]["replication"]["username"]         = ""
default["percona"]["server"]["replication"]["password"]         = ""
default["percona"]["server"]["replication"]["port"]             = 3306

# XtraBackup Settings
default["percona"]["backup"]["configure"]                       = false
default["percona"]["backup"]["username"]                        = "backup"
default["percona"]["backup"]["password"]                        = "123-changeme"

# XtraDB Cluster Settings
default["percona"]["cluster"]["binlog_format"]                  = "ROW"
default["percona"]["cluster"]["wsrep_provider"]                 = "/usr/lib64/libgalera_smm.so"
default["percona"]["cluster"]["wsrep_cluster_address"]          = ""
default["percona"]["cluster"]["wsrep_slave_threads"]            = 2
default["percona"]["cluster"]["wsrep_cluster_name"]             = ""
default["percona"]["cluster"]["wsrep_sst_method"]               = "rsync"
default["percona"]["cluster"]["wsrep_node_name"]                = ""
default["percona"]["cluster"]["innodb_locks_unsafe_for_binlog"] = 1
default["percona"]["cluster"]["innodb_autoinc_lock_mode"]       = 2
```

## Explicit my.cnf templating

In some situation it is preferable to explicitly define the attributes needed in a my.cnf file. This is enabled by adding categories to the `node[:percona][:conf]` attributes. All keys found in the `node[:percona][:conf]` map will represent categories in the my.cnf file. Each category contains a map of attributes that will be written to the my.cnf file for that category. See the example for more details.

### Example:

```ruby
node["percona"]["conf"]["mysqld"]["slow_query_log_file"] = "/var/lib/mysql/data/mysql-slow.log"
```

This configuration would write the mysqld category to the my.cnf file and have an attribute `slow_query_log_file` whose value would be `/var/lib/mysql/data/mysql-slow.log`.

### Example output (my.cnf):

```ini
[mysqld]
slow_query_log_file = /var/lib/mysql/data/mysql-slow.log
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

Many thanks go to the following who have contributed to making this cookbook even better:

* **[@jagcrete](https://github.com/jagcrete)**
  * configurable keyserver
  * encrypted password data bag
  * custom my.cnf file
* **[@pwelch](https://github.com/pwelch)**
  * ensure cookbook dependencies are loaded
  * [Foodcritic](http://acrmp.github.com/foodcritic/) compliance updates
  * various minor patches and updates
* **[@masv](https://github.com/masv)**
  * compatibility updates for 5.5

## License

Author:: Phil Cohen (<github@phlippers.net>) [![endorse](http://api.coderwall.com/phlipper/endorsecount.png)](http://coderwall.com/phlipper)

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
