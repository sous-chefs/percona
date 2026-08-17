# Percona Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/percona.svg)](https://supermarket.chef.io/cookbooks/percona)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

## Description

Installs the [Percona MySQL](http://www.percona.com/software/percona-server) client and/or
server components. (We are attempting to leverage the Sous-Chefs
MySQL cookbook as much as possible.)

Optionally installs:

* [XtraBackup](https://www.percona.com/software/mysql-database/percona-xtrabackup) hot backup software
* [Percona Toolkit](https://www.percona.com/software/database-tools/percona-toolkit) advanced command-line tools
* [XtraDB Cluster](https://www.percona.com/software/mysql-database/percona-xtradb-cluster) high availability and high scalability solution for MySQL.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

### Supported Platforms

This cookbook supports the following platforms (64-bit):

* AlmaLinux 8+
* Rocky Linux 8+
* CentOS Stream 9+
* Debian 12+
* Ubuntu 22.04+ LTS

**Note:** EOL Percona Server 5.7 has been removed.

### Cookbooks

* [yum](https://supermarket.chef.io/cookbooks/yum)

### Chef

Chef >= 16 is required. Chef 17+ is recommended for full resource compatibility.

## Migration

This cookbook now exposes custom resources only. Recipes and node attributes were removed in the breaking custom resource migration. See [migration.md](migration.md) for replacement examples.

## Resources

* [`percona_repository`](documentation/resource_percona_repository.md): Manage Percona package repositories.
* [`percona_client`](documentation/resource_percona_client.md): Install Percona client packages.
* [`percona_server`](documentation/resource_percona_server.md): Install and configure Percona Server.
* [`percona_server_config`](documentation/resource_percona_server_config.md): Manage server configuration files and service state.
* [`percona_backup`](documentation/resource_percona_backup.md): Install Percona XtraBackup and backup grants.
* [`percona_toolkit`](documentation/resource_percona_toolkit.md): Install Percona Toolkit.
* [`percona_cluster`](documentation/resource_percona_cluster.md): Install and configure Percona XtraDB Cluster.
* [`percona_ssl`](documentation/resource_percona_ssl.md): Manage replication SSL files.
* [`percona_access_grants`](documentation/resource_percona_access_grants.md): Manage grant SQL.
* [`percona_replication`](documentation/resource_percona_replication.md): Manage replication SQL.
* [`percona_mysql_user`](documentation/resource_percona_mysql_user.md): Manage Percona MySQL users and privileges.
* [`percona_mysql_database`](documentation/resource_percona_mysql_database.md): Manage Percona MySQL databases and execute SQL queries.

## Resource Documentation

See the files in [documentation/](documentation/) for full details on custom resources, properties, actions, and usage examples.

## Usage

This cookbook installs the Percona MySQL components if not present, and pulls updates if they are installed on the
system.

This cookbook uses inclusive terminology, replacing terms such as `master/slave` with `source/replica` as per [upstream MySQL terminology updates](https://dev.mysql.com/blog-archive/mysql-terminology-updates/). Older Percona releases may still use legacy terms in configuration, but all attributes, properties, and variable names in this cookbook use the new terminology. Future major releases will only support the new terms.

### Encrypted Passwords

This cookbook requires [Encrypted Data Bags](https://docs.chef.io/secrets/#encrypt-a-data-bag-item) for managing passwords and secrets. If you do not use encrypted data bags or override passwords via node attributes, empty passwords will be used (not recommended).

By default, the cookbook expects a data bag named `passwords`. You can override this with the `encrypted_data_bag` property. Optionally, specify a data bag secret file with `encrypted_data_bag_secret_file`.

Required items:

* `mysql` (for MySQL/Percona passwords)
* `system` (for system-level secrets)

Refer to Chef documentation for setup details. Example data bag items are provided in the test suite under `test/integration/data_bags/passwords/`.

You also may set expected item names via `encrypted_data_bag_item_mysql` and `encrypted_data_bag_item_system`.

### Skip passwords

Set the `skip_passwords` property to skip setting up passwords. This removes the need for the encrypted data bag if using chef-solo. It is useful for development and CI environments where you just want to use the root user with no password. If you do this, set `server_config(debian_username: 'root')` also.

### Skip Configure

Set `configure_server false` on `percona_server` to skip server configuration directly after install. This is mostly useful in a wrapper cookbook context. You can then perform pre-configuration actions and call `percona_server_config` where necessary.

#### mysql item

The mysql item should contain entries for root, backup, and replication. If no value is found, the cookbook will fall back to the default non-encrypted password.

#### system item

The "system" item should contain an entry for the Debian system user specified in `server_config[:debian_username]`. If no such entry is found, the cookbook falls back to the resource property password.

Example: "passwords" data bag - this example assumes that `server_config(debian_username: 'spud')` is used.

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

### Install client development package

To install the package including header files needed to compile software using the client library (`percona-server-devel` on RHEL-family systems, `libperconaserverclient21-dev` for Percona 8.0 on Debian/Ubuntu, and `libperconaserverclient22-dev` for Percona 8.4 on Debian/Ubuntu), set `install_devel_package true` on `percona_client`. This property is disabled by default.

### Replication over SSL

To enable SSL based replication, set `server_config(replication: { ssl_enabled: true })` and add a data bag item
to the Percona encrypted data bag with the id `ssl_replication` that contains this data:

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

All certificates and keys have to be converted to a string (easiest way is to use ruby: `/usr/bin/env ruby -e 'p ARGF.read' <filename>`) and placed
instead of CA_CERTIFICATE_STRING, SERVER_CERTIFICATE_STRING, SERVER_KEY_STRING, CLIENT_CERTIFICATE_STRING, CLIENT_KEY_STRING.

### Percona XtraDB Cluster

Below is a minimal example setup to bootstrap a Percona XtraDB Cluster. Please see the [official documentation](https://www.percona.com/doc/percona-xtradb-cluster/8.0/index.html) for more information. This is not a perfect example. It is just a sample to get you started.

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
node.override['percona']['cluster']['wsrep_cluster_address'] = cluster_address
node.override['percona']['cluster']['wsrep_node_name'] = node['hostname']

percona_cluster 'default' do
  cluster_config(
    wsrep_cluster_address: cluster_address,
    wsrep_node_name: node['hostname']
  )
end

percona_backup 'default'
percona_toolkit 'default'
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

## Explicit my.cnf templating

In some situations it is preferable to explicitly define the settings needed in a `my.cnf` file. This is enabled by passing categories through the `extra_config` property. All keys found in the `extra_config` map represent categories in the `my.cnf` file.

### Example

```ruby
percona_server 'default' do
  extra_config(
    mysqld: {
      slow_query_log_file: '/var/lib/mysql/data/mysql-slow.log'
    }
  )
end
```

This configuration would write the `mysqld` category to the `my.cnf` file and have an attribute `slow_query_log_file` whose value would be `/var/lib/mysql/data/mysql-slow.log`.

### Example output (my.cnf)

```ini
[mysqld]
slow_query_log_file = /var/lib/mysql/data/mysql-slow.log
```

## Dynamically setting the bind address

Set `server_config(bind_to: ...)` to dynamically set the bind address. This accepts `"public_ip"`, `"private_ip"`, `"loopback"`, or an interface name like `"eth0"`.

## Goals

In no particular order:

* Be the most flexible way to setup a MySQL distribution through Chef
  * Support for Chef Solo
  * Support for Chef Server
* Support the following common database infrastructures:
  * Single server instance
  * Traditional Source/Replica replication
  * Multi-source cluster replication
* Support the most recent Chef runtime environments
* Be the easiest way to setup a MySQL distribution through Chef

## TODO

* Fully support all of the standard Chef-supported distributions

## Contributing

* Fork it
* Create your feature branch (`git checkout -b my-new-feature`)
* Commit your changes (`git commit -am 'Added some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create new Pull Request

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![<https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40>)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![<https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100>)
![<https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100>)
![<https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100>)
![<https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100>)
![<https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100>)
![<https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100>)
![<https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100>)
![<https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100>)
![<https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100>)
![<https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100>)
