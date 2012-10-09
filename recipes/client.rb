include_recipe "percona::package_repo"

case node["platform_family"]
when "debian"
  package "percona-server-client" do
    options "--force-yes"
  end
when "rhel"
  package "Percona-Server-client-55"
end
