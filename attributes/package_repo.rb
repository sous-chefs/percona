#
# Cookbook:: percona
# Attributes:: package_repo
#

default['percona']['use_percona_repos'] = true
# From 8.0 onward, Percona has split up each product into individual repositories
# See https://www.percona.com/doc/percona-repo-config/index.html for more information
default['percona']['repositories'] = %w(ps-80)
default['percona']['apt']['key'] = '9334A25F8507EFA5'
default['percona']['apt']['keyserver'] = 'keyserver.ubuntu.com'
default['percona']['apt']['uri'] = 'http://repo.percona.com/apt'
default['percona']['yum']['description'] = 'Percona Packages'
default['percona']['yum']['baseurl'] = 'http://repo.percona.com/yum/release/$releasever/RPMS'
default['percona']['yum']['gpgkey'] = [
  'https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
  'https://repo.percona.com/yum/RPM-GPG-KEY-Percona',
]
default['percona']['yum']['gpgcheck'] = true
default['percona']['yum']['sslverify'] = true
