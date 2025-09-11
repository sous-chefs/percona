control 'toolkit' do
  desc 'Ensure Percona toolkit are installed.'
  impact 1.0

  if os.family == 'redhat'
    describe package 'percona-toolkit' do
      it { should_not be_installed }
    end
  else
    describe package 'percona-toolkit' do
      it { should be_installed }
    end
  end
end
