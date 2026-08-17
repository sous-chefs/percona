# frozen_string_literal: true

require 'spec_helper'

describe 'percona_repository' do
  step_into :percona_repository

  context 'on ubuntu' do
    platform 'ubuntu', '24.04'

    recipe do
      percona_repository 'default'
    end

    it { is_expected.to install_package(%w(ca-certificates curl)) }
    it { is_expected.to run_execute('download percona-release dpkg') }
    it { is_expected.to install_dpkg_package('percona-release') }
    it { is_expected.to add_apt_repository('percona-ps-84-lts') }
  end

  context 'on ubuntu with Percona 8.0' do
    platform 'ubuntu', '24.04'

    recipe do
      percona_repository 'default' do
        version '8.0'
      end
    end

    it { is_expected.to add_apt_repository('percona-ps-80') }
  end

  context 'on ubuntu with Percona XtraDB Cluster 8.0' do
    platform 'ubuntu', '24.04'

    recipe do
      percona_repository 'default' do
        version '8.0'
        cluster true
      end
    end

    it { is_expected.to add_apt_repository('percona-pxc-80') }
  end

  context 'on almalinux' do
    platform 'almalinux', '9'

    recipe do
      percona_repository 'default'
    end

    before do
      stubs_for_provider('percona_repository[default]') do |provider|
        allow(provider).to receive_shell_out('dnf -q module list mysql', returns: [0, 1])
          .and_return(double(stdout: "mysql 8.4 client, server [d]\n", error!: nil))
      end
    end

    it { is_expected.to install_package(%w(ca-certificates curl)) }
    it { is_expected.to run_execute('download percona-release rpm') }
    it { is_expected.to install_package('percona-release') }
    it { is_expected.to create_yum_repository('percona-ps-84-lts') }
    it { is_expected.to disable_dnf_module('mysql') }
  end

  context 'on almalinux when the mysql dnf module is unavailable' do
    platform 'almalinux', '10'

    recipe do
      percona_repository 'default'
    end

    before do
      stubs_for_provider('percona_repository[default]') do |provider|
        allow(provider).to receive_shell_out('dnf -q module list mysql', returns: [0, 1])
          .and_return(double(stdout: '', error!: nil))
      end
    end

    it { is_expected.to install_package('percona-release') }
    it { is_expected.to create_yum_repository('percona-ps-84-lts') }
    it { is_expected.not_to disable_dnf_module('mysql') }
  end
end
