# frozen_string_literal: true

module Percona
  module Cookbook
    class EncryptedPasswords
      attr_reader :node, :bag, :secret_file, :mysql_item, :system_item

      def initialize(node, bag: 'passwords', secret_file: '', mysql_item: 'mysql', system_item: 'system', use_chef_vault: false)
        @node = node
        @bag = bag
        @secret_file = secret_file
        @mysql_item = mysql_item
        @system_item = system_item
        @use_chef_vault = use_chef_vault
      end

      def find_password(item, user, default = nil)
        passwords = password_item(item)
        passwords[user] || default
      rescue StandardError
        Chef::Log.info("Unable to load password for #{user}, #{item}; falling back to resource property")
        default
      end

      def root_password(default)
        find_password(mysql_item, 'root', default)
      end

      def debian_password(username, default)
        find_password(system_item, username, default)
      end

      def old_passwords(default)
        find_password(mysql_item, 'old_passwords', default)
      end

      def replication_password(username, default)
        find_password(mysql_item, username, default)
      end

      def backup_password(username, default)
        find_password(mysql_item, username, default)
      end

      private

      def password_item(item)
        return ChefVault::Item.load(bag, item) if @use_chef_vault

        Chef::EncryptedDataBagItem.load(bag, item, secret) # rubocop:disable Chef/Modernize/DatabagHelpers
      end

      def data_bag_secret_file
        if !secret_file.to_s.empty? && ::File.exist?(secret_file)
          secret_file
        elsif Chef::Config[:encrypted_data_bag_secret] && !Chef::Config[:encrypted_data_bag_secret].empty?
          Chef::Config[:encrypted_data_bag_secret]
        end
      end

      def secret
        return unless data_bag_secret_file

        Chef::EncryptedDataBagItem.load_secret(data_bag_secret_file)
      end
    end
  end
end
