
include_recipe 'percona::package_repo'

# install packages
case node['platform_family']
when 'debian'
  node.default['percona']['server']['package'] = "percona-server-server-#{version}"

  package node['percona']['server']['package'] do
    options '--force-yes'
    action node['percona']['server']['package_action'].to_sym
  end
when 'rhel'
  node.default['percona']['server']['package'] = "Percona-Server-server-#{version.tr('.', '')}"
  node.default['percona']['server']['shared_pkg'] = "Percona-Server-shared-#{version.tr('.', '')}"

  # Need to remove this to avoid conflicts
  package 'mysql-libs' do
    action :remove
    not_if "rpm -qa | grep #{node['percona']['server']['shared_pkg']}"
  end

  # we need mysqladmin
  include_recipe 'percona::client'

  package node['percona']['server']['package'] do
    action node['percona']['server']['package_action'].to_sym
  end
end
