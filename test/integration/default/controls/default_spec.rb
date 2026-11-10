# frozen_string_literal: true

version = input('version', value: '8.4')
devel = input('devel', value: false)
repo_ver = version == '8.0' ? '80' : '84-lts'
client_devel_package = version == '8.0' ? 'libperconaserverclient21-dev' : 'libperconaserverclient22-dev'
os_rel = os.release.to_i

control 'client' do
  desc 'Ensure Percona client and toolkit are installed.'
  impact 1.0

  if os.family == 'debian'
    %W(prel telemetry pmm2-client tools ps-#{repo_ver}).each do |repo|
      describe apt "https://repo.percona.com/#{repo}/apt" do
        it { should exist }
        it { should be_enabled }
      end
    end
  else
    describe yum.repo 'percona-release' do
      it { should exist }
      it { should be_enabled }
    end

    describe yum.repo "percona-ps-#{repo_ver}" do
      it { should exist }
      it { should be_enabled }
      its('baseurl') { should cmp "https://repo.percona.com/ps-#{repo_ver}/yum/release/#{os_rel}/RPMS/x86_64" }
    end
  end

  describe package 'percona-server-client' do
    it { should be_installed }
  end

  describe package 'percona-toolkit' do
    it { should be_installed }
  end

  describe command 'mysql --version' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Ver #{Regexp.escape(version)}/) }
  end

  if devel
    describe package(os.family == 'debian' ? client_devel_package : 'percona-server-devel') do
      it { should be_installed }
    end
  end
end
