name              "percona"
maintainer        "Phil Cohen"
maintainer_email  "github@phlippers.net"
license           "Apache 2.0"
description       "Installs Percona MySQL client and server"
long_description  "Please refer to README.md"
version           "0.1.0"

recipe "percona",         "Sets up the apt repository and installs dependent packages"
recipe "percona::client", "Installs client libraries"
recipe "percona::server", "Installs the server daemon"

%w[debian ubuntu].each do |os|
  supports os
end
