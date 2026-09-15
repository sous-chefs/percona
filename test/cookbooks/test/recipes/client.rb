# frozen_string_literal: true

percona_version = node['percona'] ? node['percona']['version'] || '8.4' : '8.4'
install_devel_package = node['percona'] && node['percona']['client'] && node['percona']['client']['install_devel_package']

percona_client 'default' do
  version percona_version
  install_devel_package install_devel_package if install_devel_package
end

percona_toolkit 'default' do
  version percona_version
end
