require 'spec_helper'

describe 'percona::toolkit' do
  describe 'Ubuntu' do
    platform 'ubuntu'

    it do
      expect(chef_run).to install_package('percona-toolkit')
    end
  end

  describe 'CentOS' do
    platform 'centos', '7'

    before do
      stub_command('dnf module list mysql | grep -q "^mysql.*\\[x\\]"')
    end

    it do
      expect(chef_run).to install_package('percona-toolkit')
    end
    context 'CentOS 8 & Percona 8.0' do
      platform 'centos', '8'
      override_attributes['percona']['version'] = '8.0'
      it do
        expect(chef_run).to_not install_package('percona-toolkit')
      end
    end
  end
end
