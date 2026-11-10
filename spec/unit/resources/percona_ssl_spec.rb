# frozen_string_literal: true

require 'spec_helper'

describe 'percona_ssl' do
  step_into :percona_ssl
  platform 'ubuntu', '24.04'

  recipe do
    percona_ssl 'default' do
      certificates(
        'ca-cert' => 'ca',
        'server' => { 'server-cert' => 'server-cert', 'server-key' => 'server-key' },
        'client' => { 'client-cert' => 'client-cert', 'client-key' => 'client-key' }
      )
      server_roles %w(source replica)
    end
  end

  it { is_expected.to create_directory('/etc/mysql/ssl') }
  it { is_expected.to create_file('/etc/mysql/ssl/cacert.pem').with(sensitive: true) }
  it { is_expected.to create_file('/etc/mysql/ssl/server-cert.pem') }
  it { is_expected.to create_file('/etc/mysql/ssl/client-cert.pem') }
end
