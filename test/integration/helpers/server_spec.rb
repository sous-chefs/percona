def server_test(version)
  if os.family == 'debian'
    describe package "percona-server-server-#{version}" do
      it { should be_installed }
    end

    if os.release.to_i >= 10
      describe package 'percona-xtrabackup-80' do
        it { should be_installed }
      end
    else
      describe package 'xtrabackup' do
        it { should be_installed }
      end
    end

    describe package 'libjemalloc1' do
      it { should be_installed }
    end

    describe file '/etc/mysql/my.cnf' do
      it { should be_a_file }
      its('owner') { should cmp 'root' }
      its('group') { should cmp 'root' }
      its('mode') { should cmp '0644' }
    end

    if version.to_f < 5.7
      describe file '/etc/mysql/grants.sql' do
        its('content') { should match 'debian-sys-maint' }
        its('content') { should match /0kb\)F\?Zj/ }
      end
    end

    describe file '/etc/mysql/debian.cnf' do
      it { should be_a_file }
      its('owner') { should cmp 'root' }
      its('group') { should cmp 'root' }
      its('mode') { should cmp '0640' }
      its('content') { should match /0kb\)F\?Zj/ }
    end
  end

  if os.family == 'rhel'
    ver = version.tr('.', '')
    describe package "Percona-Server-devel-#{ver}" do
      it { should be_installed }
    end

    if os.release.to_i >= 8
      describe package 'percona-xtrabackup-80' do
        it { should be_installed }
      end
    else
      describe package 'xtrabackup' do
        it { should be_installed }
      end
    end

    describe package "Percona-Server-client-#{ver}" do
      it { should be_installed }
    end

    describe package "Percona-Server-server-#{ver}" do
      it { should be_installed }
    end

    describe package 'jemalloc' do
      it { should be_installed }
    end

    describe file '/etc/my.cnf' do
      it { should be_a_file }
      its('owner') { should cmp 'root' }
      its('group') { should cmp 'root' }
      its('mode') { should cmp '0644' }
    end
  end

  describe file '/root/.my.cnf' do
    it { should be_a_file }
    its('owner') { should cmp 'root' }
    its('group') { should cmp 'root' }
    its('mode') { should cmp '0600' }
    its('content') { should match /7tCk\(V5I/ }
  end

  describe file '/etc/mysql' do
    it { should be_a_directory }
    its('owner') { should cmp 'root' }
    its('group') { should cmp 'root' }
    its('mode') { should cmp '0755' }
  end

  describe file '/var/lib/mysql' do
    it { should be_a_directory }
    its('owner') { should cmp 'mysql' }
    its('group') { should cmp  'mysql' }
  end

  describe file '/var/log/mysql' do
    it { should be_a_directory }
    its('owner') { should cmp 'mysql' }
    its('group') { should cmp  'mysql' }
  end

  describe file '/tmp' do
    it { should be_a_directory }
    its('owner') { should cmp 'mysql' }
    its('group') { should cmp 'mysql' }
  end

  describe service 'mysql' do
    it { should be_enabled }
    it { should be_running }
  end

  describe command 'pgrep mysql' do
    its(:stdout) { should match(/\d+/) }
    its(:exit_status) { should eq 0 }
  end

  describe port 3306 do
    it { should be_listening }
  end

  # user_frm = version.to_f < 5.7 ? '/var/lib/mysql/mysql/user.frm' : '/tmp/mysql/mysql/user.frm'

  describe file '/tmp/mysql/mysql/user.frm' do
    it { should be_a_file }
    its('owner') { should cmp 'mysql' }
    its('group') { should cmp 'mysql' }
  end

  describe file '/etc/mysql/grants.sql' do
    it { should be_a_file }
    its('owner') { should cmp 'root' }
    its('group') { should cmp 'root' }
    its('mode') { should cmp '0600' }
    its('content') { should match /7tCk\(V5I/ }
  end

  describe file '/etc/mysql/replication.sql' do
    it { should_not be_a_file }
  end

  describe file '/tmp/mysql' do
    it { should be_a_directory }
    its('owner') { should cmp 'mysql' }
    its('group') { should cmp 'mysql' }
  end

  mysql_mode = version.to_f < 5.7 ? '0660' : '0640'

  describe file '/tmp/mysql/ibdata1' do
    it { should be_a_file }
    its('owner') { should cmp 'mysql' }
    its('group') { should cmp 'mysql' }
    its('mode') { should cmp mysql_mode }
  end

  describe file '/tmp/mysql/mysql/user.frm' do
    it { should be_a_file }
    its('owner') { should cmp 'mysql' }
    its('group') { should cmp 'mysql' }
    its('mode') { should cmp mysql_mode }
  end

  describe command "mysqladmin --user='root' --password='7tCk(V5I' variables" do
    its(:stdout) { should match %r{datadir\s+| /tmp/mysql/} }
    its(:stdout) { should match %r{general_log_file\s+| /tmp/mysql/} }
    its(:exit_status) { should eq 0 }
  end
end
