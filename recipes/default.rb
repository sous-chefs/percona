#
# Cookbook Name:: percona
# Recipe:: default
#

# include Opscode LWRP apt cookbook
include_recipe 'apt'

# configure apt repository
apt_repository "percona" do
  uri "http://repo.percona.com/apt"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver node["percona"]["keyserver"]
  key "1C4CBDCDCD2EFD2A"
  action :add
  notifies :run, "execute[apt-get update]", :immediately
end

# install dependent package
package "libmysqlclient-dev" do
  options "--force-yes"
end
