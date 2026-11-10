# frozen_string_literal: true

provides :percona_client
unified_mode true

use '_partial/_repository'

property :packages, Array, default: []
property :install_devel_package, [true, false], default: false
property :package_action, Symbol, default: :install, equal_to: %i(install upgrade remove purge)
property :configure_repository, [true, false], default: true

action_class do
  include Percona::Cookbook::Helpers
end

action :install do
  percona_repository 'percona' do
    version new_resource.version
    cluster new_resource.cluster
    apt_key new_resource.apt_key
    apt_uri new_resource.apt_uri
    yum_description new_resource.yum_description
    yum_baseurl new_resource.yum_baseurl
    yum_gpgkey new_resource.yum_gpgkey
    yum_gpgcheck new_resource.yum_gpgcheck
    yum_sslverify new_resource.yum_sslverify
    action :create
    only_if { new_resource.configure_repository }
  end

  package 'percona client packages' do
    package_name lazy {
      packages = new_resource.packages.empty? ? percona_client_package_names(version: new_resource.version, cluster: new_resource.cluster) : new_resource.packages
      packages += [percona_devel_package(version: new_resource.version)] if new_resource.install_devel_package
      packages
    }
    action new_resource.package_action
  end
end

action :remove do
  package 'percona client packages' do
    package_name lazy {
      packages = new_resource.packages.empty? ? percona_client_package_names(version: new_resource.version, cluster: new_resource.cluster) : new_resource.packages
      packages += [percona_devel_package(version: new_resource.version)] if new_resource.install_devel_package
      packages
    }
    action :remove
  end
end
