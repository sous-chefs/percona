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
  default['percona']['client']['packages'] =
    if node['percona']['version'].to_f >= 8.0
      %w(percona-server-client)
    else
      %W(percona-server-client-#{version})
    end
when 'rhel'
  default['percona']['client']['packages'] =
    if node['percona']['version'].to_f >= 8.0
      %w(percona-server-client)
    else
      %W(Percona-Server-client-#{version})
    end
end
