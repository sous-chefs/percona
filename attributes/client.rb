client = default["percona"]["client"]
version = node["percona"]["version"]

case node["platform_family"]
when "debian"
  client["packages"] = ["libperconaserverclient-dev-#{version}",
                        "percona-server-client-#{version}"]
when "rhel"
  client["packages"] = ["Percona-Server-devel-#{version.tr(',', '')}",
                        "Percona-Server-client-#{version.tr(',', '')}"]
end
