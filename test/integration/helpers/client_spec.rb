def client_test(version)
  if os.family == 'debian'
    describe file '/etc/apt/sources.list.d/percona.list' do
      it { should be_a_file }
      its('content') { should match 'http://repo.percona.com/apt' }
    end

    describe file '/etc/apt/preferences.d/00percona.pref' do
      it { should be_a_file }
      its('content') { should match 'release o=Percona Development Team' }
    end

    describe package "percona-server-client-#{version}" do
      it { should be_installed }
    end

  else
    describe yum.repo 'percona-x86_64' do
      it { should exist }
      it { should be_enabled }
    end

    describe yum.repo 'percona-noarch' do
      it { should exist }
      it { should be_enabled }
    end

    describe package "Percona-Server-client-#{version.tr('.', '')}" do
      it { should be_installed }
    end
  end

  describe package 'percona-toolkit' do
    it { should be_installed }
  end

  describe command 'mysql --version' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /Distrib #{version.tr('.', '\.')}.+/ }
  end
end
