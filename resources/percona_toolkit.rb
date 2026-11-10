# frozen_string_literal: true

provides :percona_toolkit
unified_mode true

use '_partial/_repository'

property :package_action, Symbol, default: :install, equal_to: %i(install upgrade remove purge)
property :configure_repository, [true, false], default: true

action :install do
  percona_repository 'percona' do
    version new_resource.version
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

  package 'percona-toolkit' do
    action new_resource.package_action
  end
end

action :remove do
  package 'percona-toolkit' do
    action :remove
  end
end
