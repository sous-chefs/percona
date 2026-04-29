# frozen_string_literal: true

percona_version = node['percona']['version'] || '8.4'

percona_client 'default' do
  version percona_version
  install_devel_package node['percona']['client']['install_devel_package'] if node['percona']['client']['install_devel_package']
end

percona_toolkit 'default' do
  version percona_version
end
