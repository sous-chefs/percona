# frozen_string_literal: true

control 'server' do
  desc 'Ensure Percona server is installed and configured.'
  impact 1.0

  describe package 'percona-server-server' do
    it { should be_installed }
  end

  if os.family == 'debian'
    describe file '/etc/mysql/my.cnf' do
      it { should be_a_file }
      its('owner') { should cmp 'root' }
      its('group') { should cmp 'root' }
      its('mode') { should cmp '0644' }
    end

    describe file '/etc/mysql/debian.cnf' do
      it { should be_a_file }
      its('mode') { should cmp '0640' }
      its('content') { should match /0kb\)F\?Zj/ }
    end
  else
    describe file '/etc/my.cnf' do
      it { should be_a_file }
      its('owner') { should cmp 'root' }
      its('group') { should cmp 'root' }
      its('mode') { should cmp '0644' }
    end

    describe file '/etc/systemd/system/mysqld.service.d/limits.conf' do
      it { should be_a_file }
      its('content') { should match /LimitNOFILE=16384/ }
    end
  end

  describe file '/root/.my.cnf' do
    it { should be_a_file }
    its('owner') { should cmp 'root' }
    its('group') { should cmp 'root' }
    its('mode') { should cmp '0600' }
    its('content') { should match /7tCk\(V5I/ }
  end

  describe file '/etc/mysql/grants.sql' do
    it { should be_a_file }
    its('mode') { should cmp '0600' }
    its('content') { should match /7tCk\(V5I/ }
  end

  describe file '/tmp/mysql' do
    it { should be_a_directory }
    its('owner') { should cmp 'mysql' }
    its('group') { should cmp 'mysql' }
  end

  describe service 'mysql' do
    it { should be_enabled }
    it { should be_running }
  end

  describe port 3306 do
    it { should be_listening }
  end
end
