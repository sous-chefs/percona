client = default["percona"]["client"]
version = node["percona"]["version"]

case node["platform_family"]
when "debian"
  if node["lsb"]["codename"] == "trusty"
    abi_version = case version
                  when "5.5" then "18"
                  when "5.6" then "18.1"
                  end
  end
  client["packages"] = ["libperconaserverclient#{abi_version}-dev",
                        "percona-server-client"]
when "rhel"
  client["packages"] = ["Percona-Server-devel-#{version.tr(',', '')}",
                        "Percona-Server-client-#{version.tr(',', '')}"]
end
