version = input('version')
type = input('type')
devel = input('devel')

control 'client' do
  desc 'Ensure Percona clients are installed.'
  impact 1.0

  if os.family == 'debian'
    describe apt 'http://repo.percona.com/apt' do
      it { should exist }
      it { should be_enabled }
    end

    if type == 'cluster' && version.to_i >= 8
      describe apt 'http://repo.percona.com/pxc-80/apt' do
        it { should exist }
        it { should be_enabled }
      end
    elsif version.to_i >= 8
      describe apt 'http://repo.percona.com/ps-80/apt' do
        it { should exist }
        it { should be_enabled }
      end
    else
      describe apt 'http://repo.percona.com/ps-80/apt' do
        it { should_not exist }
        it { should_not be_enabled }
      end
    end

    describe file '/etc/apt/preferences.d/00percona.pref' do
      it { should be_a_file }
      its('content') { should match 'release o=Percona Development Team' }
    end

    if type == 'cluster' && version.to_i >= 8
      describe package 'percona-xtradb-cluster-client' do
        it { should be_installed }
        its('version') { should >= '1:8' }
      end
    elsif type == 'cluster'
      describe package "percona-xtradb-cluster-client-#{version}" do
        it { should be_installed }
      end
    elsif version.to_i >= 8
      describe package 'percona-server-client' do
        it { should be_installed }
        its('version') { should >= '8' }
      end
    else
      describe package "percona-server-client-#{version}" do
        it { should be_installed }
      end
    end

    if devel == true
      if version.to_i >= 8
        describe package 'libperconaserverclient21-dev' do
          it { should be_installed }
        end
      elsif version == '5.7'
        describe package 'libperconaserverclient20-dev' do
          it { should be_installed }
        end
      elsif version == '5.6'
        describe package 'libperconaserverclient18.1-dev' do
          it { should be_installed }
        end
      end
    elsif version.to_i >= 8
      describe package 'libperconaserverclient21-dev' do
        it { should_not be_installed }
      end
    elsif version == '5.7'
      describe package 'libperconaserverclient20-dev' do
        it { should_not be_installed }
      end
    elsif version == '5.6'
      describe package 'libperconaserverclient18.1-dev' do
        it { should_not be_installed }
      end
    end

  else
    describe yum.repo 'percona' do
      it { should exist }
      it { should be_enabled }
    end

    describe yum.repo 'percona-noarch' do
      it { should exist }
      it { should be_enabled }
    end

    if type == 'cluster' && version.to_i >= 8
      describe package 'percona-xtradb-cluster-client' do
        it { should be_installed }
        its('version') { should >= '8' }
      end
    elsif type == 'cluster'
      describe package "Percona-XtraDB-Cluster-client-#{version.tr('.', '')}" do
        it { should be_installed }
      end
    elsif version.to_i >= 8
      describe package 'percona-server-client' do
        it { should be_installed }
        its('version') { should >= '8' }
      end
    else
      describe package "Percona-Server-client-#{version.tr('.', '')}" do
        it { should be_installed }
      end
    end

    if devel == true
      if version.to_i >= 8
        describe package 'percona-server-devel' do
          it { should be_installed }
        end
      else
        describe package "Percona-Server-devel-#{version.tr('.', '')}" do
          it { should be_installed }
        end
      end
    else
      describe package "Percona-Server-devel-#{version.tr('.', '')}" do
        it { should_not be_installed }
      end
      describe package 'percona-server-devel' do
        it { should_not be_installed }
      end
    end

  end

  describe command 'mysql --version' do
    its('exit_status') { should eq 0 }
    if version.to_i >= 8
      its('stdout') { should match /Ver #{version.tr('.', '\.')}.+/ }
    else
      its('stdout') { should match /Distrib #{version.tr('.', '\.')}.+/ }
    end
  end
end
