version = input('version')
type = input('type')
devel = input('devel')
os_rel = os.release.to_i
repo_ver =
  case version
  when '8.0'
    version.tr('.', '')
  when '8.4'
    "#{version.tr('.', '')}-lts"
  end

control 'client' do
  desc 'Ensure Percona clients are installed.'
  impact 1.0

  if os.family == 'debian'
    describe apt 'https://repo.percona.com/prel/apt' do
      it { should exist }
      it { should be_enabled }
    end

    describe apt 'https://repo.percona.com/telemetry/apt' do
      it { should exist }
      it { should be_enabled }
    end

    describe apt 'https://repo.percona.com/pmm2-client/apt' do
      it { should exist }
      it { should be_enabled }
    end

    describe apt 'https://repo.percona.com/tools/apt' do
      it { should exist }
      it { should be_enabled }
    end

    if type == 'cluster'
      describe apt "https://repo.percona.com/pxc-#{repo_ver}/apt" do
        it { should exist }
        it { should be_enabled }
      end
    else
      describe apt "https://repo.percona.com/ps-#{repo_ver}/apt" do
        it { should exist }
        it { should be_enabled }
      end
    end

    if type == 'cluster'
      describe package 'percona-xtradb-cluster-client' do
        it { should be_installed }
        its('version') { should >= '1:8' }
      end
    else
      describe package 'percona-server-client' do
        it { should be_installed }
        its('version') { should >= '8' }
      end
    end

    if devel == true
      case version
      when '8.0'
        describe package 'libperconaserverclient21-dev' do
          it { should be_installed }
        end
      when '8.4'
        describe package 'libperconaserverclient22-dev' do
          it { should be_installed }
        end
      end
    end

  else
    describe yum.repo 'percona-release' do
      it { should exist }
      it { should be_enabled }
      its('baseurl') { should cmp "https://repo.percona.com/prel/yum/release/#{os_rel}/RPMS/noarch" }
    end

    describe yum.repo 'percona-telemetry' do
      it { should exist }
      it { should be_enabled }
      its('baseurl') { should cmp "https://repo.percona.com/telemetry/yum/release/#{os_rel}/RPMS/x86_64" }
    end

    describe yum.repo 'percona-pmm2-client' do
      it { should exist }
      it { should be_enabled }
      its('baseurl') { should cmp "https://repo.percona.com/pmm2-client/yum/release/#{os_rel}/RPMS/x86_64" }
    end if os_rel < 10

    describe yum.repo 'percona-tools' do
      it { should exist }
      it { should be_enabled }
      its('baseurl') { should cmp "https://repo.percona.com/tools/yum/release/#{os_rel}/RPMS/x86_64" }
    end if os_rel < 10

    %w(
      percona-prel-release
      percona-telemetry-release
    ).each do |r|
      describe yum.repo r do
        it { should_not exist }
        it { should_not be_enabled }
      end
    end

    if type == 'cluster'
      describe yum.repo "percona-pxc-#{repo_ver}" do
        it { should exist }
        it { should be_enabled }
      end

      describe yum.repo 'percona-tools' do
        it { should exist }
        it { should be_enabled }
      end

      describe package 'percona-xtradb-cluster-client' do
        it { should be_installed }
        its('version') { should >= '8' }
      end
    else
      describe yum.repo "percona-ps-#{repo_ver}" do
        it { should exist }
        it { should be_enabled }
        its('baseurl') { should cmp "https://repo.percona.com/ps-#{repo_ver}/yum/release/#{os_rel}/RPMS/x86_64" }
      end

      describe package 'percona-server-client' do
        it { should be_installed }
        its('version') { should >= '8' }
      end
    end

    if devel == true
      describe package 'percona-server-devel' do
        it { should be_installed }
      end
    else
      describe package 'percona-server-devel' do
        it { should_not be_installed }
      end
    end
  end

  describe command 'mysql --version' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /Ver #{version.tr('.', '\.')}.+/ }
  end
end
