#
# Cookbook Name:: percona
# Recipe:: default
#

# configure apt repository
template "/etc/apt/sources.list.d/percona.list" do
  mode 0644
  variables :code_name => node[:lsb][:codename]
  notifies :run, resources(:execute => "apt-get update"), :immediately
  source "percona.list.erb"
end

# install the gpg key
execute "install percona gpg key" do
  command "curl http://www.percona.com/downloads/RPM-GPG-KEY-percona | apt-key add -"
  not_if "apt-key list | grep -i percona"
end

# install dependent package
%w[libmysqlclient16-dev percona-server-common].each do |pkg|
  package pkg do
    options "--force-yes"
  end
end
