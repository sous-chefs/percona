#
# Cookbook:: percona
# Recipe:: toolkit
#

include_recipe 'percona::package_repo'

unless node['percona']['version'].to_i >= 8 && platform_family?('rhel') && node['platform_version'].to_i >= 8
  package 'percona-toolkit'
end
