case node["platform_family"]
when "debian"
  default["percona"]["client"]["packages"] = %w[
    libperconaserverclient-dev-5.5 percona-server-client-5.5
  ]
when "rhel"
  default["percona"]["client"] = %w[
    Percona-Server-devel-55 Percona-Server-client-55
  ]
end
