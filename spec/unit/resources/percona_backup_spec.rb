# frozen_string_literal: true

require 'spec_helper'

describe 'percona_backup' do
  step_into :percona_backup
  platform 'ubuntu', '24.04'

  recipe do
    percona_backup 'default' do
      skip_passwords true
    end
  end

  it { is_expected.to install_package('xtrabackup').with(package_name: 'percona-xtrabackup-84') }
end
