require 'spec_helper'

describe 'percona::package_repo' do
  context 'ubuntu' do
    platform 'ubuntu'

    it do
      expect(chef_run).to add_apt_repository('percona').with(
        uri: 'http://repo.percona.com/apt',
        components: %w(main),
        keyserver: 'keyserver.ubuntu.com',
        key: %w(9334A25F8507EFA5)
      )
    end

    it do
      expect(chef_run).to add_apt_preference('00percona').with(
        glob: '*',
        pin: 'release o=Percona Development Team',
        pin_priority: '1001'
      )
    end

    it do
      expect(chef_run).to add_apt_repository('percona-ps-80').with(
        uri: 'http://repo.percona.com/ps-80/apt',
        components: %w(main),
        keyserver: 'keyserver.ubuntu.com',
        key: %w(9334A25F8507EFA5)
      )
    end

    context 'version < 8.0' do
      override_attributes['percona']['version'] = '5.7'

      it do
        expect(chef_run).to_not add_apt_repository('percona-ps-80')
      end
    end
  end

  context 'centos' do
    platform 'centos'

    it do
      expect(chef_run).to disable_dnf_module('mysql')
    end

    it do
      expect(chef_run).to create_yum_repository('percona').with(
        description: 'Percona Packages',
        baseurl: 'http://repo.percona.com/yum/release/$releasever/RPMS/$basearch',
        gpgkey: [
          'https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
          'https://repo.percona.com/yum/RPM-GPG-KEY-Percona',
        ],
        gpgcheck: true,
        sslverify: true
      )
    end

    it do
      expect(chef_run).to create_yum_repository('percona-noarch').with(
        description: 'Percona Packages - noarch',
        baseurl: 'http://repo.percona.com/yum/release/$releasever/RPMS/noarch',
        gpgkey: [
          'https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
          'https://repo.percona.com/yum/RPM-GPG-KEY-Percona',
        ],
        gpgcheck: true,
        sslverify: true
      )
    end

    it do
      expect(chef_run).to create_yum_repository('percona-ps-80').with(
        description: 'Percona Packages - ps-80',
        baseurl: 'http://repo.percona.com/ps-80/yum/release/$releasever/RPMS/$basearch',
        gpgkey: [
          'https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
          'https://repo.percona.com/yum/RPM-GPG-KEY-Percona',
        ],
        gpgcheck: true,
        sslverify: true
      )
    end

    context 'version < 8.0' do
      override_attributes['percona']['version'] = '5.7'

      it do
        expect(chef_run).to_not create_yum_repository('percona-ps-80')
      end
    end
  end
end
