client = default["percona"]["client"]

case node["platform_family"]
when "debian"
  client["packages"] = ["libperconaserverclient-dev-5.5",
                        "percona-server-client-5.5"]
when "rhel"
  client["packages"] = ["Percona-Server-devel-55",
                        "Percona-Server-client-55"]
end
