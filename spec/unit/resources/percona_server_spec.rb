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
  it { is_expected.to create_systemd_unit('mysqld.service.d/limits.conf') }
  it { is_expected.to create_percona_server_config('percona') }
end
