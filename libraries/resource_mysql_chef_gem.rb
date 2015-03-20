require "chef/resource/lwrp_base"

class Chef
  class Resource
    # Resource to install MySQL gem on systems using Percona databases
    class MysqlChefGem < Chef::Resource::LWRPBase
      self.resource_name = :mysql_chef_gem
      actions :install, :remove
      default_action :install
    end
  end
end
