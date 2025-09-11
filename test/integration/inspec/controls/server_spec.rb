version = input('version')
type = input('type')

control 'server' do
  desc 'Ensure server is installed'
  impact 1.0

  if os.family == 'debian'
    case type
    when 'server'
      if version.to_i >= 8
        describe package 'percona-server-server' do
          it { should be_installed }
          its('version') { should >= '8.0' }
        end
      else
        describe package "percona-server-server-#{version}" do
          it { should be_installed }
        end
      end
    when 'cluster'
      if version.to_i >= 8
        describe package 'percona-xtradb-cluster-server' do
          it { should be_installed }
          its('version') { should >= '1:8.0' }
        end
      else
        describe package "percona-xtradb-cluster-server-#{version}" do
          it { should be_installed }
        end
      end
    end

    xtrabackup_pkg =
      if type == 'cluster'
        'percona-xtrabackup-24'
      else
        "percona-xtrabackup-#{version.tr('.', '')}"
      end

    describe package xtrabackup_pkg do
      if type == 'cluster'
        it { should_not be_installed }
      else
        it { should be_installed }
      end
    end unless os.family == 'redhat' && os.release.to_i >= 10

    jemalloc_pkg =
      case os.family
      when 'debian'
        'libjemalloc2'
      when 'redhat'
        'libjemalloc2'
      end

    describe package jemalloc_pkg do
      it { should be_installed }
    end

    describe file '/etc/mysql/my.cnf' do
      it { should be_a_file }
      its('owner') { should cmp 'root' }
      its('group') { should cmp 'root' }
      its('mode') { should cmp '0644' }
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

    # postfix on RHEL depends on mysql-libs, ensure it still exists when using percona
    describe package 'postfix' do
      it { should be_installed }
    end

    ver = version.tr('.', '')
    describe package "Percona-Server-devel-#{ver}" do
      it { should be_installed }
    end

    describe package 'percona-xtrabackup-80' do
      it { should be_installed }
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
    its('group') { should cmp 'mysql' }
  end

  describe service 'mysql' do
    it { should be_enabled }
    it { should be_running }
  end

  describe processes('mysqld') do
    it { should exist }
    its('users') { should include 'mysql' }
  end

  describe port 3306 do
    it { should be_listening }
  end

  describe file '/etc/mysql/grants.sql' do
    it { should be_a_file }
    its('owner') { should cmp 'root' }
    its('group') { should cmp 'root' }
    its('mode') { should cmp '0600' }
    its('content') { should match /7tCk\(V5I/ }
  end

  if type == 'source'
    describe file '/etc/mysql/replication.sql' do
      it { should be_a_file }
      its('owner') { should cmp 'root' }
      its('group') { should cmp 'root' }
      its('mode') { should cmp '0600' }
      its('content') { should match %r{\)6\$W2M\{/} }
      its('content') { should match /TO 'replication'@'%'/ }
      its('content') { should match /SOURCE_HOST='source-host'/ }
      its('content') { should match /SOURCE_USER='replication'/ }
      its('content') { should match %r{SOURCE_PASSWORD='\)6\$W2M\{/'} }
    end
  elsif type == 'replication'
    describe file '/etc/mysql/replication.sql' do
      it { should be_a_file }
      its('owner') { should cmp 'root' }
      its('group') { should cmp 'root' }
      its('mode') { should cmp '0600' }
      its('content') { should match %r{CREATE USER IF NOT EXISTS 'replication'@'%' IDENTIFIED BY '\)6\$W2M\{\/';} }
      its('content') { should match /GRANT REPLICATION SLAVE ON \*\.\* TO 'replication'@'%';/ }
      its('content') { should match /ALTER USER 'replication'@'%' REQUIRE SSL;/ }
      its('content') { should match /SOURCE_HOST='source-host'/ }
      its('content') { should match /SOURCE_USER='replication'/ }
      its('content') { should match %r{SOURCE_PASSWORD='\)6\$W2M\{/'} }
      its('content') { should match /SOURCE_SSL=1/ }
      its('content') { should match %r{SOURCE_SSL_CA='/etc/mysql/ssl/cacert.pem'} }
      its('content') { should match %r{SOURCE_SSL_CERT='/etc/mysql/ssl/server-cert.pem'} }
      its('content') { should match %r{SOURCE_SSL_KEY='/etc/mysql/ssl/server-key.pem'} }
    end
  else
    describe file '/etc/mysql/replication.sql' do
      it { should_not be_a_file }
    end
  end

  describe file '/tmp/mysql' do
    it { should be_a_directory }
    its('owner') { should cmp 'mysql' }
    its('group') { should cmp 'mysql' }
  end

  mysql_file = '/tmp/mysql/mysql.ibd'
  mysql_mode = '0640'

  describe file '/tmp/mysql/ibdata1' do
    it { should be_a_file }
    its('owner') { should cmp 'mysql' }
    its('group') { should cmp 'mysql' }
    its('mode') { should cmp mysql_mode }
  end

  describe file mysql_file do
    it { should be_a_file }
    its('owner') { should cmp 'mysql' }
    its('group') { should cmp 'mysql' }
    its('mode') { should cmp mysql_mode }
  end

  describe command "mysqladmin --user='root' --password='7tCk(V5I' variables" do
    its('stdout') { should match %r{datadir\s+\| /tmp/mysql/} }
    its('stdout') { should match %r{general_log_file\s+\| /tmp/mysql/} }
    its('stdout') { should match /max_connections\s+\| 30/ }
    its('stdout') { should match /table_open_cache\s+\| 8172/ } unless os.family == 'debian' # (open_files_limit - 10 - max_connections) / 2
    its('stdout') { should match /open_files_limit\s+\| 16384/ } unless os.family == 'debian'
    its('exit_status') { should eq 0 }
  end
end
