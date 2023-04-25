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

- [XtraBackup](https://www.percona.com/software/mysql-database/percona-xtrabackup) hot backup software
- [Percona Toolkit](https://www.percona.com/software/database-tools/percona-toolkit) advanced command-line tools
- [XtraDB Cluster](https://www.percona.com/software/mysql-database/percona-xtradb-cluster) high availability and high scalability solution for MySQL.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

### Supported Platforms

We provide an expanding set of tests against the following 64-bit platforms which match what upstream supports:

- CentOS 7+
- Debian 10+
- Ubuntu 18.04+ LTS

### Cookbooks

- [yum-epel](https://supermarket.chef.io/cookbooks/yum-epel)
- [line](https://supermarket.chef.io/cookbooks/line)

### Chef

This cookbook requires Chef >= 16.

## Recipes

- `percona` - The default which includes the client recipe.
- `percona::package_repo` - Sets up the package repository and installs common packages.
- `percona::client` - Installs the Percona MySQL client libraries.
- `percona::server` - Installs and configures the Percona MySQL server daemon.
- `percona::backup` - Installs and configures the Percona XtraBackup hot backup software.
- `percona::toolkit` - Installs the Percona Toolkit software
- `percona::cluster` - Installs the Percona XtraDB Cluster server components
- `percona::configure_server` - Used internally to manage the server configuration.
- `percona::replication` - Used internally to grant permissions for replication.
- `percona::access_grants` - Used internally to grant permissions for recipes.
- `percona::ssl` - Used internally to setup ssl certificates for server/client.

## Resources

- [`percona_mysql_user`](https://github.com/sous-chefs/percona/blob/master/documentation/resource_percona_mysql_user.md)
- [`percona_mysql_database`](https://github.com/sous-chefs/percona/blob/master/documentation/resource_percona_mysql_database.md)

## Usage

This cookbook installs the Percona MySQL components if not present, and pulls updates if they are installed on the
system.

This cookbook uses inclusion terminology where applicable replacing terms such as ``master/slave`` to ``source/replica``
which matches the [terminology decided upstream](https://mysqlhighavailability.com/mysql-terminology-updates/). Older
releases of Percona still use the terms in their configuration so those will remain, however we will be using the newer
terms with attributes, property and variable names.  Currently both terms should work however the next major release of
this cookbook will only use the new terminology.

### Encrypted Passwords

This cookbook requires [Encrypted Data Bags](https://docs.chef.io/secrets/#encrypt-a-data-bag-item). If you forget to use them or do not use a node attribute to overwrite them empty passwords will be used.

To use encrypted passwords, you must create an encrypted data bag. This cookbook assumes a data bag named `passwords`, but you can override the name using the `node['percona']['encrypted_data_bag']` attribute.  You can also optionally specify a data bag secret file to be loaded for the secret key using the `node['percona']['encrypted_data_bag_secret_file']` attribute.

This cookbook expects a `mysql` item  and a `system` item. Please refer to the official documentation on how to get this setup. It actually uses a MySQL example so it can be mostly copied. Ensure you cover the data bag items as described below.

You also may set expected item names via attributes `node['percona']['encrypted_data_bag_item_mysql']` and `node['percona']['encrypted_data_bag_item_system']`.

### Skip passwords

Set the `['percona']['skip_passwords']` attribute to skip setting up passwords. Removes the need for the encrypted data bag if using chef-solo. Is useful for setting up development and ci environments where you just want to use the root user with no password. If you are doing this you may want to set `['percona']['server']['debian_username']` to be `"root"` also.

### Skip Configure

Set the `['percona']['skip_configure']` attribute to skip having the server recipe include the configure\_server recipe directly after install. This is mostly useful in a wrapper cookbook sort of context. Once skipped, you can then perform any pre-config actions your wrapper needs to, such as dropping a custom configuration file or init script or cleaning up incorrectly sized innodb logfiles. You can then include configure\_server where necessary.

#### mysql item

The mysql item should contain entries for root, backup, and replication. If no value is found, the cookbook will fall back to the default non-encrypted password.

#### system item

The "system" item should contain an entry for the debian system user as specified in the `node['percona']['server']['debian_username']` attribute. If no such entry is found, the cookbook will fall back to the default non-encrypted password.

Example: "passwords" data bag - this example assumes that `node['percona']['server']['debian_username'] = spud`

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

To install the package including header files needed to compile software using the client library (`percona-server-devel` on Centos and `libperconaserverclient-dev` on Debian), set `node['percona']['client']['install_devel_package']` to `true`. This will add those packages to the list to be installed when running the `percona::client` recipe. This attribute is disabled by default.

### Replication over SSL

To enable SSL based replication, you will need to flip the attribute `node['percona']['server']['replication']['ssl_enabled']` to `true` and add a new data\_bag item
to the percona encrypted data\_bag (see`node['percona']['encrypted_data_bag']` attribute) with the id `ssl_replication` ( see `node['percona']['encrypted_data_bag_item_ssl_replication']` attribute) that contains this data:

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

## Explicit my.cnf templating

In some situations it is preferable to explicitly define the attributes needed in a `my.cnf` file. This is enabled by adding categories to the `node['percona']['conf']` attributes. All keys found in the `node['percona']['conf']` map will represent categories in the `my.cnf` file. Each category contains a map of attributes that will be written to the `my.cnf` file for that category. See the example for more details.

### Example

```ruby
node['percona']['conf']['mysqld']['slow_query_log_file'] = "/var/lib/mysql/data/mysql-slow.log"
```

This configuration would write the `mysqld` category to the `my.cnf` file and have an attribute `slow_query_log_file` whose value would be `/var/lib/mysql/data/mysql-slow.log`.

### Example output (my.cnf)

```ini
[mysqld]
slow_query_log_file = /var/lib/mysql/data/mysql-slow.log
```

## Dynamically setting the bind address

There's a special attribute `node['percona']['server']['bind_to']` that allows you to dynamically set the bind address. This attribute accepts the values `"public_ip"`, `"private_ip"`, `"loopback"`, or and interface name like `"eth0"`. Based on this, the recipe will find a corresponding ipv4 address, and override the `node['percona']['server']['bind_address']` attribute.

## Goals

In no particular order:

- Be the most flexible way to setup a MySQL distribution through Chef
  - Support for Chef Solo
  - Support for Chef Server
- Support the following common database infrastructures:
  - Single server instance
  - Traditional Source/Replica replication
  - Multi-source cluster replication
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

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
