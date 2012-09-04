include_recipe "percona::package_repo"

package "percona-server-client" do
  options "--force-yes"
end
