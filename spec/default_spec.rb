require 'spec_helper'

describe 'percona::default' do
  platform 'ubuntu'

  before do
    stub_command('apt-key list | grep 8507EFA5')
  end

  it do
    expect(chef_run).to include_recipe('percona::client')
  end
end
