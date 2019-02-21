# require 'spec_helper'

# describe 'percona::toolkit' do
#   let(:toolkit_package) do
#     'percona-toolkit'
#   end

#   describe 'Ubuntu' do
#     let(:chef_run) do
#       ChefSpec::SoloRunner.new.converge(described_recipe)
#     end

#     specify do
#       expect(chef_run).to install_package(toolkit_package)
#     end
#   end

#   describe 'CentOS' do
#     describe 'when `version` is 5.5' do
#       let(:chef_run) do
#         env_options = { platform: 'centos', version: '6' }
#         ChefSpec::SoloRunner.new(env_options) do |node|
#           node.default['percona']['version'] = '5.5'
#         end.converge(described_recipe)
#       end

#       specify do
#         expect(chef_run).to install_package(toolkit_package)
#       end
#     end

#     describe 'when `version` is 5.6' do
#       let(:chef_run) do
#         env_options = { platform: 'centos', version: '6' }
#         ChefSpec::SoloRunner.new(env_options) do |node|
#           node.default['percona']['version'] = '5.6'
#         end.converge(described_recipe)
#       end

#       specify do
#         expect(chef_run).to install_package(toolkit_package)
#       end
#     end
#   end
# end
