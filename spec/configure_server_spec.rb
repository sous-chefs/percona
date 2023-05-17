require 'spec_helper'

describe 'percona::configure_server' do
  platform 'ubuntu'
  describe 'first run' do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('var/lib/mysql/mysql/user.frm').and_return(false)
      allow(File).to receive(:exist?).with('/var/lib/mysql.ibd').and_return(false)
      stub_command("mysqladmin --user=root --password='' version").and_return(true)
    end

    describe 'inclusion tests' do
      context 'role master' do
        override_attributes['percona']['server']['role'] = %w(master)
        it do
          expect(Chef::Log).to receive(:warn).with('Please use source/replica instead of master/slave for the role name. The next major release of the percona cookbook will only support the new terms.')
          chef_run
        end
      end
      context 'role slave' do
        override_attributes['percona']['server']['role'] = %w(slave)
        it do
          expect(Chef::Log).to receive(:warn).with('Please use source/replica instead of master/slave for the role name. The next major release of the percona cookbook will only support the new terms.')
          chef_run
        end
      end
    end

    it 'creates the main server config file' do
      expect(chef_run).to create_template('/etc/mysql/my.cnf').with(
        owner: 'root',
        group: 'root',
        mode: '0644',
        cookbook: 'percona',
        source: 'my.cnf.main.erb',
        manage_symlink_source: false,
        force_unlink: true
      )

      expect(chef_run).to render_file('/etc/mysql/my.cnf').with_content(
        'performance_schema=OFF'
      )

      resource = chef_run.template('/etc/mysql/my.cnf')
      expect(resource).to notify('execute[setup mysql datadir]').to(:run).immediately
      expect(resource).to notify('service[mysql]').to(:restart).immediately
    end

    it 'creates the data directory' do
      expect(chef_run).to create_directory('/var/lib/mysql').with(
        owner: 'mysql',
        group: 'mysql',
        recursive: true
      )
    end

    it 'defines the setup for the data directory' do
      expect(chef_run).to nothing_execute('setup mysql datadir').with(command: 'mysqld --defaults-file=/etc/mysql/my.cnf --user=mysql --initialize-insecure')
    end

    context 'version < 5.7' do
      override_attributes['percona']['version'] = '5.6'
      it 'defines the setup for the data directory' do
        expect(chef_run).to nothing_execute('setup mysql datadir').with(command: 'mysql_install_db --defaults-file=/etc/mysql/my.cnf --user=mysql')
      end
    end

    it 'creates the log directory' do
      expect(chef_run).to create_directory('log directory').with(
        path: '/var/log/mysql',
        owner: 'mysql',
        group: 'mysql',
        recursive: true
      )
    end

    it 'do not create duplicated slow query log directory' do
      expect(chef_run).to_not create_directory('slow query log directory').with(
        path: '/var/log/mysql',
        owner: 'mysql',
        group: 'mysql',
        recursive: true
      )
    end

    it 'does not create temporary directory since it is /tmp' do
      expect(chef_run).to_not create_directory('/tmp')
    end

    it 'creates the configuration include directory' do
      expect(chef_run).to create_directory('/etc/mysql/conf.d/').with(
        owner: 'mysql',
        group: 'mysql',
        recursive: true
      )
    end

    it 'updates the root user password' do
      expect(chef_run).to run_execute('Update MySQL root password')
    end
  end

  describe 'subsequent runs' do
    override_attributes['percona']['main_config_file'] = '/mysql/my.cnf'
    override_attributes['percona']['server']['root_password'] = 's3kr1t'
    override_attributes['percona']['server']['debian_password'] = 'd3b1an'
    override_attributes['percona']['server']['performance_schema'] = true
    override_attributes['percona']['conf']['mysqld']['datadir'] = '/mysql/data'
    override_attributes['percona']['conf']['mysqld']['tmpdir'] = '/mysql/tmp'
    override_attributes['percona']['conf']['mysqld']['includedir'] = '/mysql/conf.d'

    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('var/lib/mysql/mysql/user.frm').and_return(true)
      allow(File).to receive(:exist?).with('/var/lib/mysql.ibd').and_return(true)
      stub_command("mysqladmin --user=root --password='' version").and_return(false)
    end

    it 'creates a `.my.cnf` file for root' do
      expect(chef_run).to create_template('/root/.my.cnf').with(
        owner: 'root',
        group: 'root',
        mode: '0600',
        sensitive: true
      )

      expect(chef_run).to render_file('/root/.my.cnf').with_content('s3kr1t')
    end

    it 'creates the configuration directory' do
      expect(chef_run).to create_directory('/etc/mysql').with(
        owner: 'root',
        group: 'root',
        mode: '0755'
      )
    end

    it 'creates the data directory' do
      expect(chef_run).to create_directory('/mysql/data').with(
        owner: 'mysql',
        group: 'mysql',
        recursive: true
      )
    end

    it 'creates the temporary directory' do
      expect(chef_run).to create_directory('/mysql/tmp').with(
        owner: 'mysql',
        group: 'mysql',
        recursive: true
      )
    end

    it 'creates the configuration include directory' do
      expect(chef_run).to create_directory('/mysql/conf.d').with(
        owner: 'mysql',
        group: 'mysql',
        recursive: true
      )
    end

    it 'creates the slow query log directory' do
      expect(chef_run).to create_directory('/var/log/mysql').with(
        owner: 'mysql',
        group: 'mysql',
        recursive: true
      )
    end

    it 'manages the `mysql` service' do
      expect(chef_run).to enable_service('mysql')
    end

    it 'defines the setup for the data directory' do
      expect(chef_run).to nothing_execute('setup mysql datadir')
    end

    it 'creates the main server config file' do
      expect(chef_run).to create_template('/mysql/my.cnf').with(
        owner: 'root',
        group: 'root',
        mode: '0644',
        sensitive: true,
        cookbook: 'percona',
        source: 'my.cnf.main.erb'
      )

      expect(chef_run).to render_file('/mysql/my.cnf').with_content(
        'performance_schema=ON'
      )

      resource = chef_run.template('/mysql/my.cnf')
      expect(resource).to notify('execute[setup mysql datadir]').to(:run).immediately
      expect(resource).to notify('service[mysql]').to(:restart).immediately
    end

    it 'does not update the root user password' do
      expect(chef_run).to_not run_execute('Update MySQL root password')
    end

    it 'creates the debian system user config file' do
      debian_cnf = '/etc/mysql/debian.cnf'

      expect(chef_run).to create_template(debian_cnf).with(
        owner: 'root',
        group: 'root',
        mode: '0640',
        sensitive: true
      )

      expect(chef_run).to render_file(debian_cnf).with_content('d3b1an')

      resource = chef_run.template(debian_cnf)
      expect(resource).to notify('service[mysql]').to(:restart).immediately
    end
  end

  describe 'custom slow query log directory' do
    override_attributes['percona']['server']['slow_query_logdir'] = '/var/log/slowq'

    before do
      stub_command("mysqladmin --user=root --password='' version").and_return(true)
    end

    it 'creates the slow query log directory' do
      expect(chef_run).to create_directory('/var/log/slowq').with(
        owner: 'mysql',
        group: 'mysql',
        recursive: true
      )
    end
  end

  describe 'jemalloc enabled' do
    before do
      stub_command("mysqladmin --user=root --password='' version").and_return(true)
    end

    override_attributes['percona']['server']['jemalloc'] = true

    context 'Debian 10' do
      platform 'debian', '10'

      it do
        expect(chef_run).to install_package 'libjemalloc2'
      end

      it 'sets the correct malloc-lib path' do
        expect(chef_run).to render_file('/etc/mysql/my.cnf').with_content(
          %r{^malloc-lib.*= /usr/lib/x86_64-linux-gnu/libjemalloc.so.2}
        )
      end
    end
    context 'Debian 11' do
      platform 'debian', '11'

      it do
        expect(chef_run).to install_package 'libjemalloc2'
      end

      it 'sets the correct malloc-lib path' do
        expect(chef_run).to render_file('/etc/mysql/my.cnf').with_content(
          %r{^malloc-lib.*= /usr/lib/x86_64-linux-gnu/libjemalloc.so.2}
        )
      end
    end
    context 'Ubuntu 20.04' do
      platform 'ubuntu', '20.04'

      it do
        expect(chef_run).to install_package 'libjemalloc2'
      end

      it 'sets the correct malloc-lib path' do
        expect(chef_run).to render_file('/etc/mysql/my.cnf').with_content(
          %r{^malloc-lib.*= /usr/lib/x86_64-linux-gnu/libjemalloc.so.2}
        )
      end
    end
    context 'Ubuntu 18.04' do
      platform 'ubuntu', '18.04'

      it do
        expect(chef_run).to install_package 'libjemalloc1'
      end

      it 'sets the correct malloc-lib path' do
        expect(chef_run).to render_file('/etc/mysql/my.cnf').with_content(
          %r{^malloc-lib.*= /usr/lib/x86_64-linux-gnu/libjemalloc.so.1}
        )
      end
    end
    context 'CentOS 8' do
      platform 'centos', '8'

      it do
        expect(chef_run).to install_package 'jemalloc'
      end

      it 'sets the correct malloc-lib path' do
        expect(chef_run).to render_file('/etc/my.cnf').with_content(
          %r{^malloc-lib.*= /usr/lib64/libjemalloc.so.2}
        )
      end
    end
    context 'CentOS 7' do
      platform 'centos', '7'

      it do
        expect(chef_run).to install_package 'jemalloc'
      end

      it 'sets the correct malloc-lib path' do
        expect(chef_run).to render_file('/etc/my.cnf').with_content(
          %r{^malloc-lib.*= /usr/lib64/libjemalloc.so.1}
        )
      end
    end
  end

  context '`rhel` platform family' do
    platform 'centos'

    before do
      stub_command("mysqladmin --user=root --password='' version").and_return(true)
      stub_command('dnf module list mysql | grep -q "^mysql.*\\[x\\]"')
    end

    it 'creates the main server config file' do
      expect(chef_run).to create_template('/etc/my.cnf').with(
        owner: 'root',
        group: 'root',
        mode: '0644',
        sensitive: true,
        cookbook: 'percona',
        source: 'my.cnf.main.erb'
      )

      resource = chef_run.template('/etc/my.cnf')
      expect(resource).to notify('execute[setup mysql datadir]').to(:run).immediately
      expect(resource).to notify('service[mysql]').to(:restart).immediately
    end

    it 'does not create the configuration include directory' do
      expect(chef_run).to_not create_directory('/mysql/conf.d')
    end
  end

  describe '`chef-vault` support' do
    override_attributes['percona']['use_chef_vault'] = true

    before do
      stub_command("mysqladmin --user=root --password='' version").and_return(false)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
