#
# Cookbook:: percona
# Recipe:: client
#

include_recipe 'percona::package_repo'

pkgs = node['percona']['client']['packages'].empty? ? percona_client_packages : node['percona']['client']['packages']
pkgs << percona_devel_package if node['percona']['client']['install_devel_package']

# If we are installing 8.0 on a Centos 7 instance we need to remove the existing
# mariadb-libs rpm to avoid a dependency conflict.
package 'mariadb-libs' do
  action :remove
  only_if { percona_8_on_centos_7 }
end

package pkgs do
  action node['percona']['client']['package_action'].to_sym
end

# Unfortunately, removing mariadb-libs also removes postfix...which we want.
package 'postfix'
