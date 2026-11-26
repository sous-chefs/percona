# frozen_string_literal: true

require 'spec_helper'

describe 'percona_server_config' do
  step_into :percona_server_config
  platform 'ubuntu', '24.04'

  before do
    stub_command("mysqladmin --user=root --password='' version").and_return(false)
  end

  recipe do
    percona_server_config 'default' do
      server_config(root_password: 'rootpass', debian_password: 'debianpass')
    end
  end

  it { is_expected.to create_directory('/etc/mysql') }
  it { is_expected.to create_template('/etc/mysql/my.cnf') }
  it { is_expected.to create_template('/root/.my.cnf') }
  it { is_expected.to enable_service('mysql') }
end
