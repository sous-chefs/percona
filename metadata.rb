name              'percona'
maintainer        'Sous Chefs'
maintainer_email  'help@sous-chefs.org'
license           'Apache-2.0'
description       'Installs Percona MySQL client and server'
source_url        'https://github.com/sous-chefs/chef-percona'
issues_url        'https://github.com/sous-chefs/chef-percona/issues'
version           '3.2.10'
chef_version      '>= 16.0'

depends 'yum'
depends 'yum-epel'
depends 'line'

supports 'centos'
supports 'debian'
supports 'redhat'
supports 'ubuntu'
