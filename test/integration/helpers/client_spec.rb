def client_test(version)
  if os.family == 'debian'
    describe apt 'http://repo.percona.com/apt' do
      it { should exist }
      it { should be_enabled }
    end

    if version.to_f >= 8.0
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

    if version.to_f >= 8.0
      describe package 'percona-server-client' do
        it { should be_installed }
        its('version') { should >= '8' }
      end
    else
      describe package "percona-server-client-#{version}" do
        it { should be_installed }
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

    if version.to_f >= 8.0
      describe package 'percona-server-client' do
        it { should be_installed }
        its('version') { should >= '8' }
      end
    else
      describe package "Percona-Server-client-#{version.tr('.', '')}" do
        it { should be_installed }
      end
    end
  end

  if version.to_f >= 8.0 && os.family == 'redhat' && os.release.to_i >= 8
    describe package 'percona-toolkit' do
      it { should_not be_installed }
    end
  else
    describe package 'percona-toolkit' do
      it { should be_installed }
    end
  end

  describe command 'mysql --version' do
    its('exit_status') { should eq 0 }
    if version.to_f >= 8.0
      its('stdout') { should match /Ver #{version.tr('.', '\.')}.+/ }
    else
      its('stdout') { should match /Distrib #{version.tr('.', '\.')}.+/ }
    end
  end
end
