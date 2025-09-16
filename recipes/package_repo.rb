#
# Cookbook:: percona
# Recipe:: package_repo
#

return unless node['percona']['use_percona_repos']

case node['platform_family']
when 'debian'
  percona_pkg = "#{Chef::Config[:file_cache_path]}/percona-release.dpkg"
  remote_file percona_pkg do
    source 'https://repo.percona.com/apt/percona-release_latest.generic_all.deb'
  end

  dpkg_package 'percona-release' do
    source percona_pkg
  end

  %w(
    percona-pmm2-client-release
    percona-prel-release
    percona-telemetry-release
  ).each do |r|
    apt_repository r do
      action :remove
    end
  end

  apt_repository 'percona-release' do
    uri "#{node['percona']['apt']['uri']}/prel/apt"
    components ['main']
    signed_by node['percona']['apt']['key']
  end

  apt_repository 'percona-telemetry' do
    uri "#{node['percona']['apt']['uri']}/telemetry/apt"
    components ['main']
    signed_by node['percona']['apt']['key']
  end

  apt_repository 'percona-pmm2-client' do
    uri "#{node['percona']['apt']['uri']}/pmm2-client/apt"
    components ['main']
    signed_by node['percona']['apt']['key']
  end

  apt_repository 'percona-tools' do
    uri "#{node['percona']['apt']['uri']}/tools/apt"
    components ['main']
    signed_by node['percona']['apt']['key']
  end

  percona_repos.each do |repo|
    apt_repository "percona-#{repo}" do
      uri "#{node['percona']['apt']['uri']}/#{repo}/apt"
      components ['main']
      signed_by node['percona']['apt']['key']
    end
  end
when 'rhel'
  percona_pkg = "#{Chef::Config[:file_cache_path]}/percona-release.rpm"
  remote_file percona_pkg do
    source 'https://repo.percona.com/yum/percona-release-latest.noarch.rpm'
  end

  package 'percona-release' do
    source percona_pkg
  end

  %w(
    percona-prel-release
    percona-telemetry-release
  ).each do |r|
    yum_repository r do
      action :remove
    end
  end

  dnf_module 'mysql' do
    action :disable
    only_if { node['platform_version'].to_i == 8 }
  end

  yum_repository 'percona-release' do
    description 'Percona Release'
    baseurl "#{node['percona']['yum']['baseurl']}/prel/yum/release/$releasever/RPMS/noarch"
    gpgkey node['percona']['yum']['gpgkey']
    gpgcheck node['percona']['yum']['gpgcheck']
    sslverify node['percona']['yum']['sslverify']
  end

  yum_repository 'percona-telemetry' do
    description 'Percona Telemetry'
    baseurl "#{node['percona']['yum']['baseurl']}/telemetry/yum/release/$releasever/RPMS/$basearch"
    gpgkey node['percona']['yum']['gpgkey']
    gpgcheck node['percona']['yum']['gpgcheck']
    sslverify node['percona']['yum']['sslverify']
  end

  yum_repository 'percona-pmm2-client' do
    description 'Percona Monitoring and Management Client'
    baseurl "#{node['percona']['yum']['baseurl']}/pmm2-client/yum/release/$releasever/RPMS/$basearch"
    gpgkey node['percona']['yum']['gpgkey']
    gpgcheck node['percona']['yum']['gpgcheck']
    sslverify node['percona']['yum']['sslverify']
  end if node['platform_version'].to_i < 10

  yum_repository 'percona-tools' do
    description 'Percona Tools'
    baseurl "#{node['percona']['yum']['baseurl']}/tools/yum/release/$releasever/RPMS/$basearch"
    gpgkey node['percona']['yum']['gpgkey']
    gpgcheck node['percona']['yum']['gpgcheck']
    sslverify node['percona']['yum']['sslverify']
  end if node['platform_version'].to_i < 10

  percona_repos.each do |repo|
    yum_repository "percona-#{repo}" do
      description node['percona']['yum']['description'] + ' - ' + repo
      baseurl "#{node['percona']['yum']['baseurl']}/#{repo}/yum/release/$releasever/RPMS/$basearch"
      gpgkey node['percona']['yum']['gpgkey']
      gpgcheck node['percona']['yum']['gpgcheck']
      sslverify node['percona']['yum']['sslverify']
    end
  end
end
