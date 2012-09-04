#
# Cookbook Name:: percona
# Recipe:: percona_repo
#

case node["platform"]
when "ubuntu", "debian"
  include_recipe "apt"

  apt_repository "percona" do
    uri "http://repo.percona.com/apt"
    distribution node['lsb']['codename']
    components ['main']
    keyserver node["percona"]["keyserver"]
    key "1C4CBDCDCD2EFD2A"
    action :add
  end

  # install dependent package
  package "libmysqlclient-dev" do
    options "--force-yes"
  end

when "centos", "redhat", "scientific", "amazon", "fedora"
  include_recipe "yum"
  yum_key "RPM-GPG-KEY-percona" do
    url "http://www.percona.com/downloads/RPM-GPG-KEY-percona"
    action :add
  end

  yum_repository "percona" do
    name "CentOS #{node["lsb"]["release"]} - Percona"
    url "http://repo.percona.com/centos/#{node["lsb"]["release"]}/os/#{node["kernel"]["machine"]}/"
    key "RPM-GPG-KEY-percona"
    action :add
  end
end
