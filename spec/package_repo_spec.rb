require 'spec_helper'

describe 'percona::package_repo' do
  before do
    stub_command('apt-key list | grep 8507EFA5')
    stub_command('dnf module list mysql | grep -q "^mysql.*\\[x\\]"')
  end
  context 'ubuntu' do
    platform 'ubuntu'

    it do
      expect(chef_run).to add_apt_repository('percona')
    end

    it do
      expect(chef_run).to add_apt_preference('00percona')
    end
  end

  context 'centos' do
    platform 'centos'

    it do
      expect(chef_run).to create_yum_repository('percona-x86_64').with(
        gpgkey: [
          'https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
          'https://repo.percona.com/yum/RPM-GPG-KEY-Percona',
        ]
      )
    end
    it do
      expect(chef_run).to create_yum_repository('percona-noarch').with(
        gpgkey: [
          'https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
          'https://repo.percona.com/yum/RPM-GPG-KEY-Percona',
        ]
      )
    end
  end
end
