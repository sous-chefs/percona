class Chef
  class Provider
    # Public: Provider to install `mysql2` gem for Chef
    class Mysql2ChefGem < Chef::Provider::LWRPBase
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      def action_install
        converge_by "install mysql2 chef_gem and dependencies" do
          recipe_eval do
            run_context.include_recipe "build-essential"
            run_context.include_recipe "percona::client"
          end

          chef_gem "mysql2" do
            action :install
          end
        end
      end

      def action_remove
        chef_gem "mysql2" do
          action :remove
        end
      end
    end
  end
end
