#
# Cookbook Name:: percona
# Recipe:: backup
#

node.set["percona"]["backup"]["configure"] = true

include_recipe "percona::package_repo"

case node["platform_family"]
when "debian"
  package "xtrabackup" do
    options "--force-yes"
  end
when "rhel"
  package "percona-xtrabackup"
end

# access grants
include_recipe "percona::access_grants" unless node["percona"]["skip_passwords"]
# pam_auth config
include_recipe "percona::pam_auth" if node["percona"]["enable_pamauth"]
