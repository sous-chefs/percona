# frozen_string_literal: true

require 'spec_helper'

describe 'percona_server' do
  step_into :percona_server
  platform 'almalinux', '9'

  recipe do
    percona_server 'default' do
      skip_passwords true
    end
  end

  it { is_expected.to install_package('percona server package').with(package_name: 'percona-server-server') }
  it { is_expected.to create_directory('/etc/systemd/system/mysqld.service.d') }
  it { is_expected.to create_file('/etc/systemd/system/mysqld.service.d/limits.conf').with(content: "[Service]\nLimitNOFILE=16384\n") }
  it { is_expected.to create_percona_server_config('percona') }

  context 'when removing a server' do
    recipe { percona_server('default') { action :remove } }

    it { is_expected.to delete_file('/etc/systemd/system/mysqld.service.d/limits.conf') }
    it { is_expected.not_to delete_directory('/etc/systemd/system/mysqld.service.d') }
  end
end
