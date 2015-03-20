require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class Mysql2ChefGem < Chef::Resource::LWRPBase
      self.resource_name = :mysql2_chef_gem
      actions :install, :remove
      default_action :install      
    end
  end
end
