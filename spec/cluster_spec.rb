require 'spec_helper'

describe 'percona::cluster' do
  platform 'ubuntu'

  before do
    stub_command('test -f /var/lib/mysql/mysql/user.frm').and_return(true)
    stub_command("mysqladmin --user=root --password='' version").and_return(true)
    stub_command('dnf module list mysql | grep -q "^mysql.*\\[x\\]"')
  end

  %w(
    percona::package_repo
    percona::client
    percona::configure_server
    percona::access_grants
  ).each do |r|
    it do
      expect(chef_run).to include_recipe r
    end
  end

  it do
    expect(chef_run).to_not include_recipe 'yum-epel'
  end

  describe 'version 5.6' do
    override_attributes['percona']['version'] = '5.6'

    describe 'Ubuntu' do
      it do
        expect(chef_run).to install_package 'percona-xtradb-cluster-5.6'
      end

      it do
        expect(chef_run).to install_package 'percona-xtradb-cluster-client-5.6'
      end
    end

    describe 'CentOS' do
      platform 'centos'

      it do
        expect(chef_run).to include_recipe 'yum-epel'
      end

      it do
        expect(chef_run).to install_package 'Percona-XtraDB-Cluster-56'
      end

      it do
        expect(chef_run).to install_package 'Percona-XtraDB-Cluster-client-56'
      end
    end
  end
  describe 'version 5.7' do
    override_attributes['percona']['version'] = '5.7'

    describe 'Ubuntu' do
      it do
        expect(chef_run).to install_package 'percona-xtradb-cluster-5.7'
      end

      it do
        expect(chef_run).to install_package 'percona-xtradb-cluster-client-5.7'
      end
    end

    describe 'CentOS' do
      platform 'centos'

      it do
        expect(chef_run).to include_recipe 'yum-epel'
      end

      it do
        expect(chef_run).to install_package 'Percona-XtraDB-Cluster-57'
      end

      it do
        expect(chef_run).to install_package 'Percona-XtraDB-Cluster-client-57'
      end
    end
  end
  describe 'version 8.0' do
    override_attributes['percona']['version'] = '8.0'

    describe 'Ubuntu' do
      it do
        expect(chef_run).to install_package 'percona-xtradb-cluster-server'
      end

      it do
        expect(chef_run).to install_package 'percona-xtradb-cluster-client'
      end
    end

    describe 'CentOS' do
      platform 'centos'

      it do
        expect(chef_run).to include_recipe 'yum-epel'
      end

      it do
        expect(chef_run).to install_package 'percona-xtradb-cluster-server'
      end

      it do
        expect(chef_run).to install_package 'percona-xtradb-cluster-client'
      end
    end
  end
end
