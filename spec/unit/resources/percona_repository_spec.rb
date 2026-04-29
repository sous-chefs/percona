# frozen_string_literal: true

require 'spec_helper'

describe 'percona_repository' do
  step_into :percona_repository

  context 'on ubuntu' do
    platform 'ubuntu', '24.04'

    recipe do
      percona_repository 'default'
    end

    it { is_expected.to create_remote_file(%r{/percona-release.dpkg}) }
    it { is_expected.to install_dpkg_package('percona-release') }
    it { is_expected.to add_apt_repository('percona-ps-84-lts') }
  end

  context 'on almalinux' do
    platform 'almalinux', '9'

    recipe do
      percona_repository 'default'
    end

    it { is_expected.to install_package('percona-release') }
    it { is_expected.to create_yum_repository('percona-ps-84-lts') }
    it { is_expected.to disable_dnf_module('mysql') }
  end
end
