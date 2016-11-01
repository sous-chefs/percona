#
# Cookbook Name:: percona
# Recipe:: client
#

include_recipe "percona::package_repo"

version = value_for_platform_family(
  "debian" => node["percona"]["version"],
   "rhel" => node["percona"]["version"].tr(".", "")
)

case node["platform_family"]
when "debian"
  abi_version = case version
                when "5.5" then "18"
                when "5.6" then "18.1"
                else ""
                end

  if Array(node["percona"]["server"]["role"]).include?("cluster")
    packages = %W[
      libperconaserverclient#{abi_version}-dev percona-xtradb-cluster-client-#{version}
    ]
  else
    packages = %W[
      libperconaserverclient#{abi_version}-dev percona-server-client-#{version}
    ]
  end
when "rhel"
  if Array(node["percona"]["server"]["role"]).include?("cluster")
    packages = %W[
      Percona-XtraDB-Cluster-devel-#{version} Percona-XtraDB-Cluster-client-#{version}
    ]
  else
    packages = %W[
      Percona-Server-devel-#{version} Percona-Server-client-#{version}
    ]
  end
end

packages.each do |install_package|
  package install_package do
    action node.default["percona"]["client"]["package_action"]
  end
end
