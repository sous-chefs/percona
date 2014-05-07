include_recipe "percona::package_repo"

version = node["percona"]["version"]

# install packages
case node["platform_family"]
when "debian"
  package "percona-xtradb-cluster-server-#{version}" do
    options "--force-yes"
  end
when "rhel"
  package "mysql-libs" do
    action :remove
  end

  package "Percona-XtraDB-Cluster-server"
end

include_recipe "percona::configure_server"

# access grants
include_recipe "percona::access_grants"
