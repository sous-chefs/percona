include_recipe "percona::client"
include_recipe "mysql::server"

# Yum doesn't have a simple way to pin like apt does.
if platform_family?('rhel')
  chef_gem "chef-rewind"
  require 'chef/rewind'

  node['mysql']['server']['packages'].each do |pkg|
    rewind :package => pkg do
      options "--disablerepo=base,extras,updates"
    end
  end
end
