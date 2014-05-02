version = value_for_platform_family(
  "debian" => node["percona"]["version"],
  "rhel" => node["percona"]["version"].tr(".", "")
)

case node["platform_family"]
when "debian"
  default["percona"]["client"]["packages"] = %W[
    libperconaserverclient-dev-#{version} percona-server-client-#{version}
  ]
when "rhel"
  default["percona"]["client"] = %W[
    Percona-Server-devel-#{version} Percona-Server-client-#{version}
  ]
end
