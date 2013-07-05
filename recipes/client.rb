include_recipe "percona::package_repo"
include_recipe "mysql::client"

# Yum doesn't have a simple way to pin like apt does.
if platform_family?('rhel')
  chef_gem "chef-rewind"
  require 'chef/rewind'

  node['mysql']['client']['packages'].each do |pkg|
    rewind :package => pkg do
      options "--disablerepo=base,extras,updates"
    end
  end
end
