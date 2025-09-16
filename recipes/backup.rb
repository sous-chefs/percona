#
# Cookbook:: percona
# Recipe:: backup
#

node.default['percona']['backup']['configure'] = true

include_recipe 'percona::package_repo'

# TODO: Upstream doesn't have binaries yet for EL10
return if rhel? && node['platform_version'].to_i >= 10

package 'xtrabackup' do
  package_name percona_backup_package
end

# access grants
include_recipe 'percona::access_grants' unless node['percona']['skip_passwords']
