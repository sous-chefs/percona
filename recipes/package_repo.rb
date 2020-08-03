#
# Cookbook:: percona
# Recipe:: package_repo
#

return unless node['percona']['use_percona_repos']

case node['platform_family']
when 'debian'
  # Pin this repo as to avoid upgrade conflicts with distribution repos.
  apt_preference '00percona' do
    glob '*'
    pin 'release o=Percona Development Team'
    pin_priority '1001'
  end

  apt_repository 'percona' do
    uri node['percona']['apt']['uri']
    components ['main']
    keyserver node['percona']['apt']['keyserver']
    key node['percona']['apt']['key']
    not_if "apt-key list | grep #{node['percona']['apt']['key'][-8, 8]}"
  end

when 'rhel'
  yum_repository "percona-#{node['kernel']['machine']}" do
    description node['percona']['yum']['description']
    baseurl "#{node['percona']['yum']['baseurl']}/$basearch"
    gpgkey node['percona']['yum']['gpgkey']
    gpgcheck node['percona']['yum']['gpgcheck']
    sslverify node['percona']['yum']['sslverify']
  end

  yum_repository 'percona-noarch' do
    description node['percona']['yum']['description']
    baseurl "#{node['percona']['yum']['baseurl']}/noarch"
    gpgkey node['percona']['yum']['gpgkey']
    gpgcheck node['percona']['yum']['gpgcheck']
    sslverify node['percona']['yum']['sslverify']
  end

  execute 'dnf -y module disable mysql' do
    only_if { node['platform_version'].to_i >= 8 }
    not_if 'dnf module list mysql | grep -q "^mysql.*\[x\]"'
  end
end
