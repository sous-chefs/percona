include_recipe "percona::package_repo"

# install packages
case node["platform_family"]
when "debian"
  package node["percona"]["cluster"]["package"]
when "rhel"
  package "mysql-libs" do
    action :remove
  end

  package node["percona"]["cluster"]["package"]
end

include_recipe "percona::configure_server"

# access grants
include_recipe "percona::access_grants"
