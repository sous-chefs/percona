require 'spec_helper'

describe 'percona::package_repo' do
  describe 'CentOS' do
    let(:chef_run) do
      env_options = { platform: 'centos', version: '6' }
      ChefSpec::SoloRunner.new(env_options).converge(described_recipe)
    end

    it 'sets up a yum repository for `percona`' do
      expect(chef_run).to create_yum_repository('percona')
    end

    it 'sets up a yum repository for `percona` with the 2019 GPG key' do
      expect(chef_run).to create_yum_repository('percona').with(
        gpgkey: [
          'https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
          'https://repo.percona.com/yum/RPM-GPG-KEY-Percona',
        ]
      )
    end
  end
end
