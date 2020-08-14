#
# Cookbook:: percona
# Recipe:: cluster
#

node.default['percona']['repositories'] = %w(pxc-80)
node.default['percona']['client']['packages'] = percona_cluster_client_package

include_recipe 'percona::package_repo'
include_recipe 'percona::client'

# Determine and set wsrep_sst_receive_address
if node['percona']['cluster']['wsrep_sst_receive_interface']
  sst_interface = node['percona']['cluster']['wsrep_sst_receive_interface']
  sst_port = node['percona']['cluster']['wsrep_sst_receive_port']
  ip = Percona::ConfigHelper.bind_to(node, sst_interface)
  address = "#{ip}:#{sst_port}"
  node.default['percona']['cluster']['wsrep_sst_receive_address'] = address
end

# This is required for `socat` per:
# www.percona.com/doc/percona-xtradb-cluster/5.6/installation/yum_repo.html
include_recipe 'yum-epel' if platform_family?('rhel')

# install packages
package percona_cluster_package

unless node['percona']['skip_configure']
  include_recipe 'percona::configure_server'
end

# access grants
include_recipe 'percona::access_grants' unless node['percona']['skip_passwords']
