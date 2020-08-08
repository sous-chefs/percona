require 'spec_helper'

describe 'percona::client' do
  before do
    stub_command('dnf module list mysql | grep -q "^mysql.*\\[x\\]"')
  end

  describe 'when `package_action` is `install`' do
    context 'Ubuntu' do
      platform 'ubuntu'

      it do
        expect(chef_run).to install_package 'percona-server-client'
      end

      context 'version 5.7' do
        override_attributes['percona']['version'] = '5.7'
        it do
          expect(chef_run).to install_package 'percona-server-client-5.7'
        end
      end

      context 'version 5.6' do
        override_attributes['percona']['version'] = '5.6'
        it do
          expect(chef_run).to install_package 'percona-server-client-5.6'
        end
      end
    end

    context 'CentOS' do
      platform 'centos'

      it do
        expect(chef_run).to install_package 'percona-server-client'
      end

      context 'version 5.7' do
        override_attributes['percona']['version'] = '5.7'
        it do
          expect(chef_run).to install_package 'Percona-Server-client-57'
        end
      end

      context 'version 5.6' do
        override_attributes['percona']['version'] = '5.6'
        it do
          expect(chef_run).to install_package 'Percona-Server-client-56'
        end
      end
    end
  end

  describe 'when `package_action` is `upgrade`' do
    context 'Ubuntu' do
      platform 'ubuntu'
      override_attributes['percona']['client']['package_action'] = 'upgrade'

      it do
        expect(chef_run).to upgrade_package 'percona-server-client'
      end
    end

    context 'CentOS' do
      platform 'centos'
      override_attributes['percona']['client']['package_action'] = 'upgrade'

      it do
        expect(chef_run).to upgrade_package 'percona-server-client'
      end
    end
  end
end
