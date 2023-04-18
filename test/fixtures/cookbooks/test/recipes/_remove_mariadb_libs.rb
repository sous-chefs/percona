# If we are installing 8.0 on a Centos 7 instance we need to remove the existing
# mariadb-libs rpm to avoid a dependency conflict.
package 'mariadb-libs' do
  action :remove
  only_if { platform_family?('rhel') && node['platform_version'].to_i == 7 && node['percona']['version'].to_i >= 8 }
end
