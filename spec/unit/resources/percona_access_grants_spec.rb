# frozen_string_literal: true

require 'spec_helper'

describe 'percona_access_grants' do
  step_into :percona_access_grants
  platform 'ubuntu', '24.04'

  recipe do
    percona_access_grants 'default' do
      server_config(root_password: 'rootpass', debian_password: 'debianpass')
      backup_config(password: 'backuppass')
    end
  end

  it { is_expected.to create_template('/etc/mysql/grants.sql') }
  it { is_expected.to nothing_execute('mysql-install-privileges') }
end
