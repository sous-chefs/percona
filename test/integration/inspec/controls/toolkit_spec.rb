version = input('version')

control 'toolkit' do
  desc 'Ensure Percona toolkit are installed.'
  impact 1.0

  if version.to_i >= 8 && os.family == 'redhat' && os.release.to_i >= 8
    describe package 'percona-toolkit' do
      it { should_not be_installed }
    end
  else
    describe package 'percona-toolkit' do
      it { should be_installed }
    end
  end
end
