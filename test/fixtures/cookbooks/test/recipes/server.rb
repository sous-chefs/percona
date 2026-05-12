node.default['percona']['server']['datadir'] = '/tmp/mysql'
node.default['percona']['server']['debian_password'] = '0kb)F?Zj'
node.default['percona']['server']['root_password'] = '7tCk(V5I'
node.default['percona']['backup']['password'] = 'I}=sJ2bS'
node.default['percona']['server']['jemalloc'] = if platform_family?('rhel') && node['platform_version'] >= '9'
                                                  false
                                                else
                                                  true
                                                end

# Label the non-default datadir so mysqld can access it under SELinux
if platform_family?('rhel')
  selinux_install 'percona'

  selinux_fcontext '/tmp/mysql(/.*)?' do
    secontext 'mysqld_db_t'
  end
end

include_recipe 'test::_remove_mysql_common'
include_recipe 'percona::server'
include_recipe 'percona::backup'

# Install postfix on RHEL to ensure we don't properly break mysql-libs compatibility
package 'postfix' if platform_family?('rhel')
