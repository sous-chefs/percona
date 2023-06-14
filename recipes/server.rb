#
# Cookbook:: percona
# Recipe:: server
#

include_recipe 'percona::package_repo'
include_recipe 'percona::client'

pkg = node['percona']['server']['package'].empty? ? percona_server_package : node['percona']['server']['package']

package pkg do
  action node['percona']['server']['package_action'].to_sym
end

# install packages
if platform_family?('rhel')
  # Work around issue with 5.7 on RHEL
  if node['percona']['version'].to_f >= 5.7
    execute 'systemctl daemon-reload' do
      action :nothing
    end

    delete_lines 'remove PIDFile from systemd.service' do
      path '/usr/lib/systemd/system/mysqld.service'
      pattern /^PIDFile=.*/
      notifies :run, 'execute[systemctl daemon-reload]', :immediately
    end

    replace_or_add 'configure LimitNOFILE in systemd.service' do
      path '/usr/lib/systemd/system/mysqld.service'
      pattern /^LimitNOFILE =.*/
      line "LimitNOFILE = #{node['percona']['server']['open_files_limit']}"
      notifies :run, 'execute[systemctl daemon-reload]', :immediately
    end
  end
end

unless node['percona']['skip_configure']
  include_recipe 'percona::configure_server'
end

# access grants
unless node['percona']['skip_passwords']
  include_recipe 'percona::access_grants'
  include_recipe 'percona::replication'
end
