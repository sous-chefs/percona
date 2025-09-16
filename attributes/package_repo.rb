#
# Cookbook:: percona
# Attributes:: package_repo
#

default['percona']['use_percona_repos'] = true
default['percona']['apt']['key'] = '/usr/share/keyrings/percona-keyring.gpg'
default['percona']['apt']['uri'] = 'https://repo.percona.com'
default['percona']['yum']['description'] = 'Percona Packages'
default['percona']['yum']['baseurl'] = 'https://repo.percona.com'
default['percona']['yum']['gpgkey'] = 'file:///etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY'
default['percona']['yum']['gpgcheck'] = true
default['percona']['yum']['sslverify'] = true
