#
# Cookbook:: percona
# Attributes:: client
#

# install vs. upgrade packages
default['percona']['client']['package_action'] = 'install'

version = value_for_platform_family(
  'debian' => node['percona']['version'],
  'rhel' => node['percona']['version'].tr('.', '')
)

case node['platform_family']
when 'debian'
  abi_version = case version
                when '5.5' then '18'
                when '5.6' then '18.1'
                else ''
                end

  default['percona']['client']['packages'] = if Array(node['percona']['server']['role']).include?('cluster')
                                               %W(
                                                 libperconaserverclient#{abi_version}-dev percona-xtradb-cluster-client-#{version}
                                               )
                                             else
                                               %W(
                                                 libperconaserverclient#{abi_version}-dev percona-server-client-#{version}
                                               )
                                             end
when 'rhel'
  default['percona']['client']['packages'] = if Array(node['percona']['server']['role']).include?('cluster')
                                               %W(
                                                 Percona-XtraDB-Cluster-client-#{version}
                                               )
                                             # Percona-XtraDB-Cluster-devel-#{version}
                                             else
                                               %W(
                                                 Percona-Server-client-#{version}
                                               )
                                               # Percona-Server-devel-#{version}
                                             end
end
