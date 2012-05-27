name              "percona"
maintainer        "Phil Cohen"
maintainer_email  "github@phlippers.net"
license           "Apache 2.0"
description       "Installs Percona MySQL client and server"
long_description  "Please refer to README.md"
version           "0.5.0"

recipe "percona",          "Sets up the apt repository and installs dependent packages"
recipe "percona::client",  "Installs client libraries"
recipe "percona::server",  "Installs the server daemon"
recipe "percona::backup",  "Installs the XtraBackup hot backup software"
recipe "percona::toolkit", "Installs the Percona Toolkit software"
recipe "percona::cluster", "Installs the Percona XtraDB Cluster server components"
recipe "percona::replication", "Used internally to grant permissions for replication."
recipe "percona::access_grants", "Used internally to grant permissions for recipes"

depends "apt"

%w[debian ubuntu].each do |os|
  supports os
end
