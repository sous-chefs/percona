#
# Cookbook:: percona
# Attributes:: client
#

# install vs. upgrade packages
default['percona']['client']['package_action'] = 'install'
default['percona']['client']['packages'] = []
default['percona']['client']['install_devel_package'] = false
