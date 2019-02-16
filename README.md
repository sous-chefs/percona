# Percona Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/percona.svg)](https://supermarket.chef.io/cookbooks/percona)
[![Build Status](https://img.shields.io/circleci/project/github/sous-chefs/percona/master.svg)](https://circleci.com/gh/sous-chefs/percona)
[![pullreminders](https://pullreminders.com/badge.svg)](https://pullreminders.com?ref=badge)

## Description

Installs the [Percona
MySQL](http://www.percona.com/software/percona-server) client and/or
server components. (We are attempting to leverage the Sous-Chefs
MySQL cookbook as much as possible.)

Optionally installs:

- [XtraBackup](http://www.percona.com/software/percona-xtrabackup/) hot backup software
- [Percona Toolkit](http://www.percona.com/software/percona-toolkit/) advanced command-line tools
- [XtraDB Cluster](http://www.percona.com/software/percona-xtradb-cluster/) high availability and high scalability solution for MySQL.
- [Percona Monitoring Plugins](http://www.percona.com/software/percona-monitoring-plugins) various Nagios plugins for monitoring MySQL

## Requirements

### Supported Platforms

We provide an expanding set of tests against the following 64-bit platforms:

- Amazon 2014.03
- CentOS 6.5
- CentOS 7.0
- Debian 7.8
- Ubuntu 12.04 LTS
- Ubuntu 14.04 LTS

Although we don't test against all possible platform versions, we expect
the following to be supported. Please submit an issue if this is not the
cause, and we'll make reasonable efforts to improve support:

- Ubuntu
- Debian
- Amazon Linux AMI
- CentOS
- Red Hat
- Scientific
- Fedora

### Cookbooks

- [apt](https://supermarket.getchef.com/cookbooks/apt) Chef LWRP Cookbook
- [openssl](https://supermarket.getchef.com/cookbooks/openssl) Chef Cookbook
- [yum](https://supermarket.getchef.com/cookbooks/yum) Chef LWRP Cookbook
- [yum-epel](https://supermarket.getchef.com/cookbooks/yum-epel) Chef LWRP Cookbook

### Chef

This cookbook requires Chef >= 11.14.2 due to the use of the `sensitive` attribute for some resources.

We aim to test the most recent releases of Chef. You can view
the [currently tested versions](https://github.com/phlipper/chef-percona/blob/master/.travis.yml).
(Feel free to submit a pull request if they're out of date!)

## Recipes

- `percona` - The default no-op recipe.
- `percona::package_repo` - Sets up the package repository and installs common packages.
- `percona::client` - Installs the Percona MySQL client libraries.
- `percona::server` - Installs and configures the Percona MySQL server daemon.
- `percona::backup` - Installs and configures the Percona XtraBackup hot backup software.
- `percona::toolkit` - Installs the Percona Toolkit software
- `percona::cluster` - Installs the Percona XtraDB Cluster server components
- `percona::configure_server` - Used internally to manage the server configuration.
- `percona::replication` - Used internally to grant permissions for replication.
- `percona::access_grants` - Used internally to grant permissions for recipes.
- `percona::monitoring` - Installs Percona monitoring plugins for Nagios

## Usage

This cookbook installs the Percona MySQL components if not present, and pulls updates if they are installed on the system.

### Encrypted Passwords

This cookbook requires [Encrypted Data Bags](http://wiki.opscode.com/display/chef/Encrypted+Data+Bags). If you forget to use them or do not use a node attribute to overwrite them empty passwords will be used.

To use encrypted passwords, you must create an encrypted data bag. This cookbook assumes a data bag named `passwords`, but you can override the name using the `node[:percona][:encrypted_data_bag]` attribute.  You can also optionally specify a data bag secret file to be loaded for the secret key using the `node[:percona][:encrypted_data_bag_secret_file]` attribute.

This cookbook expects a `mysql` item  and a `system` item. Please refer to the official documentation on how to get this setup. It actually uses a MySQL example so it can be mostly copied. Ensure you cover the data bag items as described below.

You also may set expected item names via attributes `node["percona"]["encrypted_data_bag_item_mysql"]` and `node["percona"]["encrypted_data_bag_item_system"]`.

### Skip passwords

Set the `["percona"]["skip_passwords"]` attribute to skip setting up passwords. Removes the need for the encrypted data bag if using chef-solo. Is useful for setting up development and ci environments where you just want to use the root user with no password. If you are doing this you may want to set `[:percona][:server][:debian_username]` to be `"root"` also.

### Skip Configure

Set the `['percona']['skip_configure']` attribute to skip having the server recipe include the configure\_server recipe directly after install. This is mostly useful in a wrapper cookbook sort of context. Once skipped, you can then perform any pre-config actions your wrapper needs to, such as dropping a custom configuration file or init script or cleaning up incorrectly sized innodb logfiles. You can then include configure\_server where necessary.

#### mysql item

The mysql item should contain entries for root, backup, and replication. If no value is found, the cookbook will fall back to the default non-encrypted password.

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

### Replication over SSL

To enable SSL based replication, you will need to flip the attribute `node[:percona][:server][:replication][:ssl_enabled]` to `true` and add a new data_bag item
to the percona encrypted data_bag (see`node[:percona][:encrypted_data_bag]` attribute) with the id `ssl_replication` ( see `node["percona"]["encrypted_data_bag_item_ssl_replication"]` attribute) that contains this data:

```javascript
{
  "id": "ssl_replication",
  "ca-cert": "CA_CERTIFICATE_STRING",
  "server": {
    "server-cert": "SERVER_CERTIFICATE_STRING",
    "server-key": "SERVER_KEY_STRING"
  },
  "client": {
    "client-cert": "CLIENT_CERTIFICATE_STRING",
    "client-key": "CLIENT_KEY_STRING"
  }
}
```

All certificates and keys have to be converted to a string (easiest way is to use ruby: */usr/bin/env ruby -e 'p ARGF.read'* **filename**) and placed
instead of CA_CERTIFICATE_STRING, SERVER_CERTIFICATE_STRING, SERVER_KEY_STRING, CLIENT_CERTIFICATE_STRING, CLIENT_KEY_STRING.

### Percona XtraDB Cluster

Below is a minimal example setup to bootstrap a Percona XtraDB Cluster. Please see the [official documentation](http://www.percona.com/doc/percona-xtradb-cluster/5.6/index.html) for more information. This is not a perfect example. It is just a sample to get you started.

Wrapper recipe recipes/percona.rb:

```ruby
# Setup the Percona XtraDB Cluster
cluster_ips = []
unless Chef::Config[:solo]
  search(:node, 'role:percona').each do |other_node|
    next if other_node['private_ipaddress'] == node['private_ipaddress']
    Chef::Log.info "Found Percona XtraDB cluster peer: #{other_node['private_ipaddress']}"
    cluster_ips << other_node['private_ipaddress']
  end
end

cluster_ips.each do |ip|
  firewall_rule "allow Percona group communication to peer #{ip}" do
    source ip
    port 4567
    action :allow
  end

  firewall_rule "allow Percona state transfer to peer #{ip}" do
    source ip
    port 4444
    action :allow
  end

  firewall_rule "allow Percona incremental state transfer to peer #{ip}" do
    source ip
    port 4568
    action :allow
  end
end

cluster_address = "gcomm://#{cluster_ips.join(',')}"
Chef::Log.info "Using Percona XtraDB cluster address of: #{cluster_address}"
node.override["percona"]["cluster"]["wsrep_cluster_address"] = cluster_address
node.override["percona"]["cluster"]["wsrep_node_name"] = node['hostname']

include_recipe 'percona::cluster'
include_recipe 'percona::backup'
include_recipe 'percona::toolkit'
```

Example percona role roles/percona.rb:

```ruby
name "percona"
description "Percona XtraDB Cluster"

run_list 'recipe[paydici::percona]'

default_attributes(
  "percona" => {
    "server" => {
      "role" => "cluster"
    },

    "cluster" => {
      "package"                     => "percona-xtradb-cluster-56",
      "wsrep_cluster_name"          => "percona_cluster_1",
      "wsrep_sst_receive_interface" => "eth1" # can be eth0, public, private, etc.
    }
  }
)
```

Now you need to bring three servers up one at a time with the percona role applied to them. By default the servers will sync up via rsync server state transfer (SST)

## Attributes

```ruby
default["percona"]["version"] = "5.6"
version = node["percona"]["version"]

# Always restart percona on configuration changes
default["percona"]["auto_restart"] = true

case node["platform_family"]
when "debian"
  default["percona"]["server"]["socket"] = "/var/run/mysqld/mysqld.sock"
  default["percona"]["server"]["default_storage_engine"] = "InnoDB"
  default["percona"]["server"]["includedir"] = "/etc/mysql/conf.d/"
  default["percona"]["server"]["pidfile"] = "/var/run/mysqld/mysqld.pid"
  default["percona"]["server"]["package"] = "percona-server-server-#{version}"
when "rhel"
  default["percona"]["server"]["socket"] = "/var/lib/mysql/mysql.sock"
  default["percona"]["server"]["default_storage_engine"] = "innodb"
  default["percona"]["server"]["includedir"] = ""
  default["percona"]["server"]["pidfile"] = "/var/lib/mysql/mysqld.pid"
  default["percona"]["server"]["package"] = "Percona-Server-server-#{version.tr(".", "")}"
  default["percona"]["server"]["shared_pkg"] = "Percona-Server-shared-#{version.tr(".", "")}"
end

# Cookbook Settings
default["percona"]["main_config_file"] = value_for_platform_family(
  "debian" => "/etc/mysql/my.cnf",
  "rhel" => "/etc/my.cnf"
)
default["percona"]["apt"]["keyserver"] = "hkp://keys.gnupg.net:80"
default["percona"]["encrypted_data_bag"] = "passwords"
default["percona"]["encrypted_data_bag_secret_file"] = ""
default["percona"]["use_chef_vault"] = false
default["percona"]["skip_passwords"] = false
default["percona"]["skip_configure"] = false

# Start percona server on boot
default["percona"]["server"]["enable"] = true

# SELinux module URL
default["percona"]["selinux_module_url"] = "https://github.com/gguillen/selinux_percona-pxc-56-cluster/raw/master/percona-pxc-56-cluster.pp"

# install vs. upgrade packages
default["percona"]["server"]["package_action"] = "install"

# Basic Settings
default["percona"]["server"]["role"] = ["standalone"]
default["percona"]["server"]["username"] = "mysql"
default["percona"]["server"]["datadir"] = "/var/lib/mysql"
default["percona"]["server"]["logdir"] = "/var/log/mysql"
default["percona"]["server"]["tmpdir"] = "/tmp"
default["percona"]["server"]["slave_load_tmpdir"] = "/tmp"
default["percona"]["server"]["debian_username"] = "debian-sys-maint"
default["percona"]["server"]["jemalloc"] = false
default["percona"]["server"]["jemalloc_lib"] = value_for_platform_family(
  "debian" => value_for_platform(
    "ubuntu" => {
      "trusty" => "/usr/lib/x86_64-linux-gnu/libjemalloc.so.1",
      "precise" => "/usr/lib/libjemalloc.so.1"
    }
  ),
  "rhel" => "/usr/lib64/libjemalloc.so.1"
)
default["percona"]["server"]["nice"]  = 0
default["percona"]["server"]["open_files_limit"]  = 16_384
default["percona"]["server"]["hostname"]  = "localhost"
default["percona"]["server"]["basedir"]  = "/usr"
default["percona"]["server"]["port"]  = 3306
default["percona"]["server"]["language"]  = "/usr/share/mysql/english"
default["percona"]["server"]["character_set"]  = "utf8"
default["percona"]["server"]["collation"]  = "utf8_unicode_ci"
default["percona"]["server"]["skip_name_resolve"]  = false
default["percona"]["server"]["skip_external_locking"]  = true
default["percona"]["server"]["net_read_timeout"]  = 120
default["percona"]["server"]["connect_timeout"]  = 10
default["percona"]["server"]["wait_timeout"]  = 28_800
default["percona"]["server"]["old_passwords"]  = 0
default["percona"]["server"]["bind_address"]  = "127.0.0.1"
default["percona"]["server"]["federated"] = false

%w[debian_password root_password].each do |attribute|
  next if attribute?(node["percona"]["server"][attribute])
  default["percona"]["server"][attribute] = secure_password
end

# Fine Tuning
default["percona"]["server"]["key_buffer_size"] = "16M"
default["percona"]["server"]["max_allowed_packet"] = "64M"
default["percona"]["server"]["thread_stack"] = "192K"
default["percona"]["server"]["query_alloc_block_size"] = "16K"
default["percona"]["server"]["memlock"] = false
default["percona"]["server"]["transaction_isolation"] = "REPEATABLE-READ"
default["percona"]["server"]["tmp_table_size"] = "64M"
default["percona"]["server"]["max_heap_table_size"] = "64M"
default["percona"]["server"]["sort_buffer_size"] = "8M"
default["percona"]["server"]["join_buffer_size"] = "8M"
default["percona"]["server"]["thread_cache_size"] = 16
default["percona"]["server"]["back_log"] = 50
default["percona"]["server"]["max_connections"] = 30
default["percona"]["server"]["max_connect_errors"] = 9_999_999
default["percona"]["server"]["sql_modes"] = []
default["percona"]["server"]["table_cache"] = 8192
default["percona"]["server"]["group_concat_max_len"] = 4096
default["percona"]["server"]["expand_fast_index_creation"] = false
default["percona"]["server"]["read_rnd_buffer_size"] = 262_144

# Query Cache Configuration
default["percona"]["server"]["query_cache_size"] = "64M"
default["percona"]["server"]["query_cache_limit"] = "2M"

# Logging and Replication
default["percona"]["server"]["sync_binlog"] = (node["percona"]["server"]["role"] == "cluster" ? 0 : 1)
default["percona"]["server"]["slow_query_log"] = 1
default["percona"]["server"]["slow_query_logdir"] = "/var/log/mysql"
default["percona"]["server"]["slow_query_log_file"] = "#{node["percona"]["server"]["slow_query_logdir"]}/mysql-slow.log"
default["percona"]["server"]["long_query_time"] = 2
default["percona"]["server"]["server_id"] = 1
default["percona"]["server"]["binlog_do_db"] = []
default["percona"]["server"]["binlog_ignore_db"] = []
default["percona"]["server"]["expire_logs_days"] = 10
default["percona"]["server"]["max_binlog_size"] = "100M"
default["percona"]["server"]["binlog_cache_size"] = "1M"
default["percona"]["server"]["binlog_format"] = "MIXED"
default["percona"]["server"]["log_bin"] = "master-bin"
default["percona"]["server"]["relay_log"] = "slave-relay-bin"
default["percona"]["server"]["log_slave_updates"] = false
default["percona"]["server"]["log_warnings"] = true
default["percona"]["server"]["log_long_format"] = false
default["percona"]["server"]["bulk_insert_buffer_size"] = "64M"

# MyISAM Specific
default["percona"]["server"]["myisam_recover_options"] = "BACKUP"
default["percona"]["server"]["myisam_sort_buffer_size"] = "128M"
default["percona"]["server"]["myisam_max_sort_file_size"] = "10G"
default["percona"]["server"]["myisam_repair_threads"] = 1
default["percona"]["server"]["read_buffer_size"] = "8M"

# InnoDB Specific
default["percona"]["server"]["skip_innodb"] = false
default["percona"]["server"]["innodb_additional_mem_pool_size"] = "32M"
default["percona"]["server"]["innodb_buffer_pool_size"] = "128M"
default["percona"]["server"]["innodb_data_file_path"] = "ibdata1:10M:autoextend"
default["percona"]["server"]["innodb_autoextend_increment"] = "128M"
default["percona"]["server"]["innodb_open_files"] = 2000
default["percona"]["server"]["innodb_file_per_table"] = true
default["percona"]["server"]["innodb_file_format"] = "Antelope"
default["percona"]["server"]["innodb_data_home_dir"] = ""
default["percona"]["server"]["innodb_thread_concurrency"] = 16
default["percona"]["server"]["innodb_flush_log_at_trx_commit"] = 1
default["percona"]["server"]["innodb_fast_shutdown"] = false
default["percona"]["server"]["innodb_log_buffer_size"] = "64M"
default["percona"]["server"]["innodb_log_file_size"] = "5M"
default["percona"]["server"]["innodb_log_files_in_group"] = 2
default["percona"]["server"]["innodb_max_dirty_pages_pct"] = 80
default["percona"]["server"]["innodb_flush_method"] = "O_DIRECT"
default["percona"]["server"]["innodb_lock_wait_timeout"] = 120
default["percona"]["server"]["innodb_import_table_from_xtrabackup"] = 0

# Performance Schema
default["percona"]["server"]["performance_schema"] = false

# Replication Settings
default["percona"]["server"]["replication"]["read_only"] = false
default["percona"]["server"]["replication"]["host"] = ""
default["percona"]["server"]["replication"]["username"] = ""
default["percona"]["server"]["replication"]["password"] = ""
default["percona"]["server"]["replication"]["port"] = 3306
default["percona"]["server"]["replication"]["ignore_db"] = []
default["percona"]["server"]["replication"]["ignore_table"] = []
default["percona"]["server"]["replication"]["ssl_enabled"] = false
default["percona"]["server"]["replication"]["suppress_1592"] = false
default["percona"]["server"]["replication"]["skip_slave_start"] = false
default["percona"]["server"]["replication"]["slave_transaction_retries"] = 10

# XtraBackup Settings
default["percona"]["backup"]["configure"] = false
default["percona"]["backup"]["username"] = "backup"
unless attribute?(node["percona"]["backup"]["password"])
  default["percona"]["backup"]["password"] = secure_password
end

# XtraDB Cluster Settings
default["percona"]["cluster"]["package"] = value_for_platform_family(
  "debian" => "percona-xtradb-cluster-#{version.tr(".", "")}",
  "rhel" => "Percona-XtraDB-Cluster-#{version.tr(".", "")}"
)
default["percona"]["cluster"]["binlog_format"] = "ROW"
default["percona"]["cluster"]["wsrep_provider"] = value_for_platform_family(
  "debian" => "/usr/lib/libgalera_smm.so",
  "rhel" => "/usr/lib64/libgalera_smm.so"
)
default["percona"]["cluster"]["wsrep_provider_options"] = ""
default["percona"]["cluster"]["wsrep_cluster_address"] = ""
default["percona"]["cluster"]["wsrep_slave_threads"] = 2
default["percona"]["cluster"]["wsrep_cluster_name"] = ""
default["percona"]["cluster"]["wsrep_sst_method"] = "rsync"
default["percona"]["cluster"]["wsrep_node_name"] = ""
default["percona"]["cluster"]["wsrep_notify_cmd"] = ""
default["percona"]["cluster"]["wsrep_sst_auth"] = ""

# These both are used to build wsrep_sst_receive_address
default["percona"]["cluster"]["wsrep_sst_receive_interface"] = nil # Works like node["percona"]["server"]["bind_to"]
default["percona"]["cluster"]["wsrep_sst_receive_port"] = "4444"

default["percona"]["cluster"]["innodb_locks_unsafe_for_binlog"] = 1
default["percona"]["cluster"]["innodb_autoinc_lock_mode"] = 2
```

### client.rb

```ruby
# install vs. upgrade packages
default["percona"]["client"]["package_action"] = "install"

version = value_for_platform_family(
  "debian" => node["percona"]["version"],
  "rhel" => node["percona"]["version"].tr(".", "")
)

case node["platform_family"]
when "debian"
  abi_version = case version
                when "5.5" then "18"
                when "5.6" then "18.1"
                else ""
                end

  default["percona"]["client"]["packages"] = %W[
    libperconaserverclient#{abi_version}-dev percona-server-client-#{version}
  ]
when "rhel"
  if Array(node["percona"]["server"]["role"]).include?("cluster")
    default["percona"]["client"]["packages"] = %W[
      Percona-XtraDB-Cluster-devel-#{version} Percona-XtraDB-Cluster-client-#{version}
    ]
  else
    default["percona"]["client"]["packages"] = %W[
      Percona-Server-devel-#{version} Percona-Server-client-#{version}
    ]
  end
end
```

### monitoring.rb

```ruby
default["percona"]["plugins_version"] = "1.1.3"
default["percona"]["plugins_packages"] = %w[percona-nagios-plugins percona-zabbix-templates percona-cacti-templates]
```

### package_repo.rb

```ruby
default["percona"]["yum"]["description"] = "Percona Packages"
default["percona"]["yum"]["baseurl"]     = "http://repo.percona.com/centos/#{pversion}/os/#{arch}/"
default["percona"]["yum"]["gpgkey"]      = [
  'https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
  'https://repo.percona.com/yum/RPM-GPG-KEY-Percona',
]
default["percona"]["yum"]["gpgcheck"]    = true
default["percona"]["yum"]["sslverify"]   = true
```

## Explicit my.cnf templating

In some situation it is preferable to explicitly define the attributes needed in a `my.cnf` file. This is enabled by adding categories to the `node[:percona][:conf]` attributes. All keys found in the `node[:percona][:conf]` map will represent categories in the `my.cnf` file. Each category contains a map of attributes that will be written to the `my.cnf` file for that category. See the example for more details.

### Example

```ruby
node["percona"]["conf"]["mysqld"]["slow_query_log_file"] = "/var/lib/mysql/data/mysql-slow.log"
```

This configuration would write the `mysqld` category to the `my.cnf` file and have an attribute `slow_query_log_file` whose value would be `/var/lib/mysql/data/mysql-slow.log`.

### Example output (my.cnf)

```ini
[mysqld]
slow_query_log_file = /var/lib/mysql/data/mysql-slow.log
```

## Dynamically setting the bind address

There's a special attribute `node["percona"]["server"]["bind_to"]` that allows you to dynamically set the bind address. This attribute accepts the values `"public_ip"`, `"private_ip"`, `"loopback"`, or and interface name like `"eth0"`. Based on this, the recipe will find a corresponding ipv4 address, and override the `node["percona"]["server"]["bind_address"]` attribute.

## MySQL Gems

This cookbook provides a MySQL and MySQL2 gem installer specifically designed for
use with Percona. Since they share namespaces with other providers you most
likely want to call them directly targeting the provider, example provided below:

```ruby
mysql2_chef_gem 'default' do
  provider Chef::Provider::Mysql2ChefGem::Percona
  action :install
end

mysql_chef_gem 'default' do
  provider Chef::Provider::MysqlChefGem::Percona
  action :install
end
```

Also keep in mind that since these providers are subclasses of the mysql_chef_gem
and mysql2_chef_gem cookbooks they need to be added to your metadata.rb file as
depends to ensure they pull in the needed resource files.

## Goals

In no particular order:

- Be the most flexible way to setup a MySQL distribution through Chef
  - Support for Chef Solo
  - Support for Chef Server
- Support the following common database infrastructures:
  - Single server instance
  - Traditional Master/Slave replication
  - Multi-master cluster replication
- Support the most recent Chef runtime environments
- Be the easiest way to setup a MySQL distribution through Chef

## TODO

- Fully support all of the standard Chef-supported distributions

## Contributing

- Fork it
- Create your feature branch (`git checkout -b my-new-feature`)
- Commit your changes (`git commit -am 'Added some feature'`)
- Push to the branch (`git push origin my-new-feature`)
- Create new Pull Request

## Contributors

Many thanks go to the following [contributors](https://github.com/phlipper/chef-percona/graphs/contributors) who have helped to make this cookbook even better:

- **[@jagcrete](https://github.com/jagcrete)**
- **[@pwelch](https://github.com/pwelch)**
- **[@masv](https://github.com/masv)**
- **[@stottsan](https://github.com/stottsan)**
- **[@abecciu](https://github.com/abecciu)**
- **[@patcon](https://github.com/patcon)**
- **[@psi](https://github.com/psi)**
- **[@TheSerapher](https://github.com/TheSerapher)**
- **[@bensomers](https://github.com/bensomers)**
- **[@tdg5](https://github.com/tdg5)**
- **[@gpendler](https://github.com/gpendler)**
- **[@vinu](https://github.com/vinu)**
- **[@ckuttruff](https://github.com/ckuttruff)**
- **[@srodrig0209](https://github.com/srodrig0209)**
- **[@jesseadams](https://github.com/jesseadams)**
- **[@see0](https://github.com/see0)**
- **[@baldur](https://github.com/baldur)**
- **[@chrisroberts](https://github.com/chrisroberts)**
- **[@aaronjensen](https://github.com/aaronjensen)**
- **[@pioneerit](https://github.com/pioneerit)**
- **[@AndreyChernyh](https://github.com/AndreyChernyh)**
- **[@avit](https://github.com/avit)**
- **[@alexzorin](https://github.com/alexzorin)**
- **[@jyotty](https://github.com/jyotty)**
- **[@adamdunkley](https://github.com/adamdunkley)**
- **[@freerobby](https://github.com/freerobby)**
- **[@spovich](https://github.com/spovich)**
- **[@v1nc3ntlaw](https://github.com/v1nc3ntlaw)**
- **[@joegaudet](https://github.com/joegaudet)**
- **[@mikesmullin](https://github.com/mikesmullin)**
- **[@totally](https://github.com/totally)**
- **[@sapunoff](https://github.com/sapunoff)**
- **[@errm](https://github.com/errm)**
- **[@ewr](https://github.com/ewr)**
- **[@jharley](https://github.com/jharley)**
- **[@achied](https://github.com/achied)**
- **[@akshah123](https://github.com/akshah123)**
- **[@tkuhlman](https://github.com/tkuhlman)**
- **[@mancdaz](https://github.com/mancdaz)**
- **[@iancoffey](https://github.com/iancoffey)**
- **[@notnmeyer](https://github.com/notnmeyer)**
- **[@odacrem](https://github.com/odacrem)**
- **[@g3kk0](https://github.com/g3kk0)**
- **[@gfloyd](https://github.com/gfloyd)**
- **[@paustin01](https://github.com/paustin01)**
- **[@ajardan](https://github.com/ajardan)**
- **[@realloc](https://github.com/realloc)**
- **[@tbunnyman](https://github.com/tbunnyman)**
- **[@mzdrale](https://github.com/mzdrale)**
- **[@Sauraus](https://github.com/Sauraus)**
- **[@jim80net](https://github.com/jim80net)**
- **[@helgi](https://github.com/helgi)**
- **[@arnesund](https://github.com/arnesund)**
- **[@n3bulous](https://github.com/n3bulous)**
- **[@runwaldarshu](https://github.com/runwaldarshu)**
- **[@vermut](https://github.com/vermut)**
- **[@dng-dev](https://github.com/dng-dev)**
- **[@washingtoneg](https://github.com/washingtoneg)**
- **[@cmjosh](https://github.com/cmjosh)**
- **[@cybermerc](https://github.com/cybermerc)**
- **[@drywheat](https://github.com/drywheat)**
- **[@joelhandwell](https://github.com/joelhandwell)**
- **[@bitpusher-real](https://github.com/bitpusher-real)**
- **[@cyberflow](https://github.com/cyberflow)**
- **[@jklare](https://github.com/jklare)**
- **[@whiteley](https://github.com/whiteley)**

## License

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
