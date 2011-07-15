include_recipe "percona::default"

package "percona-server-client" do
  options "--force-yes"
end
