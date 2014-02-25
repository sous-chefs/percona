include_recipe "percona::package_repo"

# install packages
case node["platform_family"]
when "debian"
  # The package start is up immediately, then additional config is added and the restart command fails to work.
  # Instead stop the db before changing the config.
  execute "stop_mysql" do
    action :nothing
    command '/etc/init.d/mysql stop'
  end

  package node["percona"]["cluster"]["package"] do
    notifies :run, "execute[stop_mysql]", :immediately
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
