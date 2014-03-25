include_recipe "percona::package_repo"

# install packages
case node["platform_family"]
when "debian"
  package node["percona"]["cluster"]["package"] do
    # The package starts up immediately, then additional config is added and the restart command fails to work.
    # Instead stop the db before changing the config.
    notifies :stop, "service[mysql]", :immediately
  end
 
when "rhel"
  package "mysql-libs" do
    action :remove
  end

  package node["percona"]["cluster"]["package"]
end

include_recipe "percona::configure_server"

# access grants
include_recipe "percona::access_grants"
