#
# Cookbook:: percona
# Recipe:: client
#

include_recipe 'percona::package_repo'

pkgs = node['percona']['client']['packages'].empty? ? percona_client_packages : node['percona']['client']['packages']
pkgs << percona_devel_package if node['percona']['client']['install_devel_package']

package pkgs do
  action node['percona']['client']['package_action'].to_sym
end
