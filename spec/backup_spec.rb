require 'spec_helper'

describe 'percona::backup' do
  context 'Ubuntu' do
    platform 'ubuntu'

    it { expect(chef_run).to include_recipe('percona::package_repo') }
    it { expect(chef_run).to install_package('xtrabackup') }
    it { expect(chef_run).to include_recipe('percona::access_grants') }

    context 'Ubuntu 20.04' do
      platform 'ubuntu', '20.04'
      it { expect(chef_run).to install_package('percona-xtrabackup-80') }
    end

    context 'Debian 10' do
      platform 'debian', '10'
      it { expect(chef_run).to install_package('percona-xtrabackup-80') }
    end
  end

  context 'CentOS' do
    platform 'centos'

    before do
      stub_command('dnf module list mysql | grep -q "^mysql.*\\[x\\]"')
    end

    it { expect(chef_run).to include_recipe('percona::package_repo') }
    it { expect(chef_run).to install_package('xtrabackup') }
    it { expect(chef_run).to include_recipe('percona::access_grants') }

    context 'CentOS 8' do
      platform 'centos', '8'
      it { expect(chef_run).to install_package('percona-xtrabackup-80') }
    end
  end
end
