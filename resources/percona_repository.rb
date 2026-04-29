# frozen_string_literal: true

provides :percona_repository
unified_mode true

use '_partial/_repository'

property :install_release_package, [true, false], default: true

action_class do
  include Percona::Cookbook::Helpers
end

action :create do
  validate_percona_version!(new_resource.version)

  case node['platform_family']
  when 'debian'
    release_package = "#{Chef::Config[:file_cache_path]}/percona-release.dpkg"

    remote_file release_package do
      source 'https://repo.percona.com/apt/percona-release_latest.generic_all.deb'
      action :create
      only_if { new_resource.install_release_package }
    end

    dpkg_package 'percona-release' do
      source release_package
      action :install
      only_if { new_resource.install_release_package }
    end

    %w(
      percona-pmm2-client-release
      percona-prel-release
      percona-telemetry-release
    ).each do |repo|
      apt_repository repo do
        action :remove
      end
    end

    {
      'percona-release' => 'prel',
      'percona-telemetry' => 'telemetry',
      'percona-pmm2-client' => 'pmm2-client',
      'percona-tools' => 'tools',
    }.each do |repo_name, repo_path|
      apt_repository repo_name do
        uri "#{new_resource.apt_uri}/#{repo_path}/apt"
        components ['main']
        signed_by new_resource.apt_key
      end
    end

    percona_repo_names(version: new_resource.version, cluster: new_resource.cluster).each do |repo|
      apt_repository "percona-#{repo}" do
        uri "#{new_resource.apt_uri}/#{repo}/apt"
        components ['main']
        signed_by new_resource.apt_key
      end
    end
  when 'rhel', 'fedora', 'amazon'
    release_package = "#{Chef::Config[:file_cache_path]}/percona-release.rpm"

    remote_file release_package do
      source 'https://repo.percona.com/yum/percona-release-latest.noarch.rpm'
      action :create
      only_if { new_resource.install_release_package }
    end

    package 'percona-release' do
      source release_package
      action :install
      only_if { new_resource.install_release_package }
    end

    %w(
      percona-prel-release
      percona-telemetry-release
    ).each do |repo|
      yum_repository repo do
        action :remove
      end
    end

    dnf_module 'mysql' do
      action :disable
      only_if { platform_family?('rhel', 'fedora', 'amazon') && node['platform_version'].to_i >= 8 }
    end

    {
      'percona-release' => ['Percona Release', 'prel/yum/release/$releasever/RPMS/noarch'],
      'percona-telemetry' => ['Percona Telemetry', 'telemetry/yum/release/$releasever/RPMS/$basearch'],
      'percona-pmm2-client' => ['Percona Monitoring and Management Client', 'pmm2-client/yum/release/$releasever/RPMS/$basearch'],
      'percona-tools' => ['Percona Tools', 'tools/yum/release/$releasever/RPMS/$basearch'],
    }.each do |repo_name, repo_data|
      yum_repository repo_name do
        description repo_data[0]
        baseurl "#{new_resource.yum_baseurl}/#{repo_data[1]}"
        gpgkey new_resource.yum_gpgkey
        gpgcheck new_resource.yum_gpgcheck
        sslverify new_resource.yum_sslverify
        action :create
      end
    end

    percona_repo_names(version: new_resource.version, cluster: new_resource.cluster).each do |repo|
      yum_repository "percona-#{repo}" do
        description "#{new_resource.yum_description} - #{repo}"
        baseurl "#{new_resource.yum_baseurl}/#{repo}/yum/release/$releasever/RPMS/$basearch"
        gpgkey new_resource.yum_gpgkey
        gpgcheck new_resource.yum_gpgcheck
        sslverify new_resource.yum_sslverify
        action :create
      end
    end
  end
end

action :delete do
  case node['platform_family']
  when 'debian'
    %w(
      percona-release
      percona-telemetry
      percona-pmm2-client
      percona-tools
    ).concat(percona_repo_names(version: new_resource.version, cluster: new_resource.cluster).map { |repo| "percona-#{repo}" }).each do |repo|
      apt_repository repo do
        action :remove
      end
    end
  when 'rhel', 'fedora', 'amazon'
    %w(
      percona-release
      percona-telemetry
      percona-pmm2-client
      percona-tools
    ).concat(percona_repo_names(version: new_resource.version, cluster: new_resource.cluster).map { |repo| "percona-#{repo}" }).each do |repo|
      yum_repository repo do
        action :remove
      end
    end
  end
end
