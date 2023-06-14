require 'spec_helper'

describe 'percona::server' do
  platform 'ubuntu'

  before do
    stub_command("mysqladmin --user=root --password='' version").and_return(true)
    stub_command('dnf module list mysql | grep -q "^mysql.*\\[x\\]"')
  end

  it { expect(chef_run).to include_recipe('percona::client') }

  describe 'Ubuntu' do
    platform 'ubuntu'

    it { expect(chef_run).to include_recipe('percona::package_repo') }
    it { expect(chef_run).to include_recipe('percona::configure_server') }
    it { expect(chef_run).to include_recipe('percona::access_grants') }
    it { expect(chef_run).to include_recipe('percona::replication') }
    it { expect(chef_run).to install_package('percona-server-server') }

    context 'version 5.7' do
      override_attributes['percona']['version'] = '5.7'
      it do
        expect(chef_run).to install_package 'percona-server-server-5.7'
      end
    end

    context 'version 5.6' do
      override_attributes['percona']['version'] = '5.6'
      it do
        expect(chef_run).to install_package 'percona-server-server-5.6'
      end
    end
  end

  context 'CentOS' do
    platform 'centos'

    it { expect(chef_run).to install_package('percona-server-server') }

    it do
      expect(chef_run).to nothing_execute('systemctl daemon-reload')
    end

    it do
      expect(chef_run).to edit_delete_lines('remove PIDFile from systemd.service').with(
        path: '/usr/lib/systemd/system/mysqld.service'
        # pattern: /^PIDFile=.*/ TODO: this errors out with <The diff is empty, are your objects producing identical `#inspect` output?>
      )
    end

    it do
      expect(chef_run.delete_lines('remove PIDFile from systemd.service')).to \
        notify('execute[systemctl daemon-reload]').to(:run).immediately
    end

    it do
      expect(chef_run).to edit_replace_or_add('configure LimitNOFILE in systemd.service').with(
        path: '/usr/lib/systemd/system/mysqld.service',
        line: 'LimitNOFILE = 16384'
        # pattern: /^LimitNOFILE =.*/ TODO: this errors out with <The diff is empty, are your objects producing identical `#inspect` output?>
      )
    end

    it do
      expect(chef_run.replace_or_add('configure LimitNOFILE in systemd.service')).to \
        notify('execute[systemctl daemon-reload]').to(:run).immediately
    end

    context 'version 5.7' do
      override_attributes['percona']['version'] = '5.7'
      it do
        expect(chef_run).to install_package 'Percona-Server-server-57'
      end
    end

    context 'version 5.6' do
      override_attributes['percona']['version'] = '5.6'
      it do
        expect(chef_run).to install_package 'Percona-Server-server-56'
      end
    end
  end

  describe 'when `skip_configure` is true' do
    override_attributes['percona']['skip_configure'] = true

    it { expect(chef_run).to_not include_recipe('percona::configure_server') }
  end

  describe 'when `skip_passwords` is true' do
    override_attributes['percona']['skip_passwords'] = true

    it { expect(chef_run).to_not include_recipe('percona::access_grants') }
    it { expect(chef_run).to_not include_recipe('percona::replication') }
  end

  describe 'when `package_action` is `upgrade`' do
    describe 'Ubuntu' do
      override_attributes['percona']['server']['package_action'] = 'upgrade'

      it { expect(chef_run).to upgrade_package('percona-server-server') }
    end

    context 'CentOS' do
      platform 'centos'
      override_attributes['percona']['server']['package_action'] = 'upgrade'

      it { expect(chef_run).to upgrade_package('percona-server-server') }
    end
  end
end
