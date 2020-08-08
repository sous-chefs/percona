require 'spec_helper'

describe 'percona::default' do
  platform 'ubuntu'

  it do
    expect(chef_run).to include_recipe('percona::client')
  end
end
