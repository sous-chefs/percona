#
# Cookbook Name:: percona
# Recipe:: server
#

include_recipe "percona::package_repo"

version = node["percona"]["version"]

# install packages
case node["platform_family"]
when "debian"
  # Do not start mysql on install if we are going to configure
  unless node["percona"]["skip_configure"]
    dpkg_autostart 'mysql' do
      allow false
    end
  end

  node.default["percona"]["server"]["package"] = "percona-server-server-#{version}" # rubocop:disable LineLength

  package node["percona"]["server"]["package"] do
    options "--force-yes"
    action node["percona"]["server"]["package_action"].to_sym
  end
when "rhel"
  node.default["percona"]["server"]["package"] = "Percona-Server-server-#{version.tr(".", "")}" # rubocop:disable LineLength
  node.default["percona"]["server"]["shared_pkg"] = "Percona-Server-shared-#{version.tr(".", "")}" # rubocop:disable LineLength

  # Need to remove this to avoid conflicts
  package "mysql-libs" do
    action :remove
    not_if "rpm -qa | grep #{node["percona"]["server"]["shared_pkg"]}"
  end

  # we need mysqladmin
  include_recipe "percona::client"

  package node["percona"]["server"]["package"] do
    action node["percona"]["server"]["package_action"].to_sym
  end
end

unless node["percona"]["skip_configure"]
  include_recipe "percona::configure_server"
end

# access grants
unless node["percona"]["skip_passwords"]
  include_recipe "percona::access_grants"
  include_recipe "percona::replication"
end
