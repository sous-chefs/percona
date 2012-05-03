node.set["percona"]["backup"]["configure"] = true

include_recipe "percona::default"

package "xtrabackup"

# access grants
include_recipe "percona::access_grants"
