#
# Cookbook Name:: percona
# Recipe:: package_repo
#

case node['platform_family']
  
# Repositories need to be added at Chef's Compile time using .run_action(:add), due to `chef_gem` command installing gems at compile time. For example `chef_gem 'mysql'` requires us to have percona-server-client installed at compile time - this can only happen if the percona repositories are there as well.

when "debian"
  include_recipe "apt"
  
  # Pin this repo as to avoid upgrade conflicts with distribution repos.
  apt_preference "00percona" do
    glob "*"
    pin "release o=Percona Development Team"
    pin_priority "1001"
  end.run_action(:add)

  apt_repository "percona" do
    uri node['percona']['apt_uri']
    distribution node['lsb']['codename']
    components [ "main" ]
    keyserver node['percona']['apt_keyserver']
    key node['percona']['apt_key_id']
  end.run_action(:add)

when "rhel"
  include_recipe "yum"

  yum_key "RPM-GPG-KEY-percona" do
    url "http://www.percona.com/downloads/RPM-GPG-KEY-percona"
  end.run_action(:add)

  arch = node['kernel']['machine'] == "x86_64" ? "x86_64" : "i386"
  pversion = node['platform_version'].to_i
  yum_repository "percona" do
    repo_name "Percona"
    description "Percona Repo"
    url "http://repo.percona.com/centos/#{pversion}/os/#{arch}/"
    key "RPM-GPG-KEY-percona"
  end.run_action(:add)

end
