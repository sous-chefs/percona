# frozen_string_literal: true

require 'spec_helper'

describe 'percona_backup' do
  step_into :percona_backup

  context 'with the default version' do
    platform 'ubuntu', '24.04'

    recipe do
      percona_backup 'default' do
        skip_passwords true
      end
    end

    it { is_expected.to install_package('xtrabackup').with(package_name: 'percona-xtrabackup-84') }
  end

  context 'with Percona 8.0' do
    platform 'ubuntu', '24.04'

    recipe do
      percona_backup 'default' do
        version '8.0'
        skip_passwords true
      end
    end

    it { is_expected.to install_package('xtrabackup').with(package_name: 'percona-xtrabackup-80') }
  end
end
