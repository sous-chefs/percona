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
  end

  if node['percona']['version'].to_i >= 8
    node['percona']['repositories'].each do |repo|
      apt_repository "percona-#{repo}" do
        uri "http://repo.percona.com/#{repo}/apt"
        components ['main']
        keyserver node['percona']['apt']['keyserver']
        key node['percona']['apt']['key']
      end
    end
  end

when 'rhel'
  dnf_module 'mysql' do
    action :disable
    only_if { node['platform_version'].to_i == 8 }
  end

  yum_repository 'percona' do
    description node['percona']['yum']['description']
    baseurl "#{node['percona']['yum']['baseurl']}/$basearch"
    gpgkey node['percona']['yum']['gpgkey']
    gpgcheck node['percona']['yum']['gpgcheck']
    sslverify node['percona']['yum']['sslverify']
  end

  if node['percona']['version'].to_i >= 8
    node['percona']['repositories'].each do |repo|
      yum_repository "percona-#{repo}" do
        description node['percona']['yum']['description'] + ' - ' + repo
        baseurl "http://repo.percona.com/#{repo}/yum/release/$releasever/RPMS/$basearch"
        gpgkey node['percona']['yum']['gpgkey']
        gpgcheck node['percona']['yum']['gpgcheck']
        sslverify node['percona']['yum']['sslverify']
      end
    end
  end

  yum_repository 'percona-noarch' do
    description node['percona']['yum']['description'] + ' - noarch'
    baseurl "#{node['percona']['yum']['baseurl']}/noarch"
    gpgkey node['percona']['yum']['gpgkey']
    gpgcheck node['percona']['yum']['gpgcheck']
    sslverify node['percona']['yum']['sslverify']
  end
end
