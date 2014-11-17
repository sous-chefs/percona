class Chef
  class Provider
    # rubocop:disable LineLength
    #
    # Public:
    # Monkey patch to not install mysql client dev libraries over ours
    # https://github.com/opscode-cookbooks/mysql/blob/master/libraries/provider_mysql_client_ubuntu.rb
    #
    # rubocop:enable LineLength
    class MysqlChefGem < Chef::Provider::LWRPBase
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      def action_install
        converge_by "install mysql chef_gem and dependencies" do
          recipe_eval do
            run_context.include_recipe "build-essential"
            run_context.include_recipe "percona::client"
          end

          chef_gem "mysql" do
            action :install
          end
        end
      end

      def action_remove
        chef_gem "mysql" do
          action :remove
        end
      end
    end
  end
end
