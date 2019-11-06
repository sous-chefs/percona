# require 'spec_helper'

# describe 'percona::default' do
#   let(:chef_run) do
#     ChefSpec::SoloRunner.new.converge(described_recipe)
#   end

#   it 'can converge the client recipe' do
#     stub_command('apt-key list | grep 8507EFA5').and_return 'foo'

#     expect(chef_run).to include_recipe('percona::client')
#   end
# end
