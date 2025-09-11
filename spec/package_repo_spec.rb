require 'spec_helper'

describe 'percona::package_repo' do
  context 'ubuntu' do
    platform 'ubuntu'

    it do
      is_expected.to create_remote_file("#{Chef::Config[:file_cache_path]}/percona-release.dpkg").with(
        source: 'https://repo.percona.com/apt/percona-release_latest.generic_all.deb'
      )
    end

    it do
      is_expected.to install_dpkg_package('percona-release').with(
        source: "#{Chef::Config[:file_cache_path]}/percona-release.dpkg"
      )
    end

    %w(
      percona-pmm2-client-release
      percona-prel-release
      percona-telemetry-release
    ).each do |r|
      it { is_expected.to remove_apt_repository r }
    end

    it do
      expect(chef_run).to add_apt_repository('percona-release').with(
        uri: 'https://repo.percona.com/prel/apt',
        components: %w(main),
        signed_by: '/usr/share/keyrings/percona-keyring.gpg'
      )
    end

    it do
      expect(chef_run).to add_apt_repository('percona-telemetry').with(
        uri: 'https://repo.percona.com/telemetry/apt',
        components: %w(main),
        signed_by: '/usr/share/keyrings/percona-keyring.gpg'
      )
    end

    it do
      expect(chef_run).to add_apt_repository('percona-pmm2-client').with(
        uri: 'https://repo.percona.com/pmm2-client/apt',
        components: %w(main),
        signed_by: '/usr/share/keyrings/percona-keyring.gpg'
      )
    end

    it do
      expect(chef_run).to add_apt_repository('percona-tools').with(
        uri: 'https://repo.percona.com/tools/apt',
        components: %w(main),
        signed_by: '/usr/share/keyrings/percona-keyring.gpg'
      )
    end

    it do
      expect(chef_run).to add_apt_repository('percona-ps-80').with(
        uri: 'https://repo.percona.com/ps-80/apt',
        components: %w(main),
        signed_by: '/usr/share/keyrings/percona-keyring.gpg'
      )
    end
  end

  context 'centos' do
    platform 'centos'

    it do
      expect(chef_run).to disable_dnf_module('mysql')
    end

    it do
      is_expected.to create_remote_file("#{Chef::Config[:file_cache_path]}/percona-release.rpm").with(
        source: 'https://repo.percona.com/yum/percona-release-latest.noarch.rpm'
      )
    end

    it do
      is_expected.to install_package('percona-release').with(
        source: "#{Chef::Config[:file_cache_path]}/percona-release.rpm"
      )
    end

    %w(
      percona-prel-release
      percona-telemetry-release
    ).each do |r|
      it { is_expected.to remove_yum_repository r }
    end

    it do
      expect(chef_run).to create_yum_repository('percona-release').with(
        description: 'Percona Release',
        baseurl: 'https://repo.percona.com/prel/yum/release/$releasever/RPMS/noarch',
        gpgkey: 'file:///etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY',
        gpgcheck: true,
        sslverify: true
      )
    end

    it do
      expect(chef_run).to create_yum_repository('percona-telemetry').with(
        description: 'Percona Telemetry',
        baseurl: 'https://repo.percona.com/telemetry/yum/release/$releasever/RPMS/$basearch',
        gpgkey: 'file:///etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY',
        gpgcheck: true,
        sslverify: true
      )
    end

    it do
      expect(chef_run).to create_yum_repository('percona-pmm2-client').with(
        description: 'Percona Monitoring and Management Client',
        baseurl: 'https://repo.percona.com/pmm2-client/yum/release/$releasever/RPMS/$basearch',
        gpgkey: 'file:///etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY',
        gpgcheck: true,
        sslverify: true
      )
    end

    it do
      expect(chef_run).to create_yum_repository('percona-tools').with(
        description: 'Percona Tools',
        baseurl: 'https://repo.percona.com/tools/yum/release/$releasever/RPMS/$basearch',
        gpgkey: 'file:///etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY',
        gpgcheck: true,
        sslverify: true
      )
    end

    it do
      expect(chef_run).to create_yum_repository('percona-ps-80').with(
        description: 'Percona Packages - ps-80',
        baseurl: 'https://repo.percona.com/ps-80/yum/release/$releasever/RPMS/$basearch',
        gpgkey: 'file:///etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY',
        gpgcheck: true,
        sslverify: true
      )
    end
  end
end
