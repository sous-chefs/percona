#
# Cookbook:: percona
# Recipe:: backup
#

node.default['percona']['backup']['configure'] = true

include_recipe 'percona::package_repo'

package 'xtrabackup' do
  package_name percona_backup_package
end

# access grants
include_recipe 'percona::access_grants' unless node['percona']['skip_passwords']
