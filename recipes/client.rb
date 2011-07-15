include_recipe "percona::default"

package "percona-server-client-5.1" do
  options "--force-yes"
end
