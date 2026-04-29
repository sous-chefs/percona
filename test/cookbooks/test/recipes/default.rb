# frozen_string_literal: true

percona_version = node['percona']['version'] || '8.4'

percona_client 'default' do
  version percona_version
end

percona_toolkit 'default' do
  version percona_version
end
