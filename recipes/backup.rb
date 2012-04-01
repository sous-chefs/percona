node.set[:percona][:backup][:configure] = true

include_recipe "percona::default"

package "xtrabackup"

def backup_password
  node[:percona][:backup][:password]
end

# access grants
include_recipe "percona::access_grants"
