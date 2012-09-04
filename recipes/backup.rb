node.set["percona"]["backup"]["configure"] = true

include_recipe "percona::package_repo"

package "xtrabackup"

# access grants
include_recipe "percona::access_grants"
