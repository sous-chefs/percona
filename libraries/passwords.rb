class Chef
  # Public: This class provides helpers for retrieving passwords from encrypted
  # data bags
  class EncryptedPasswords
    attr_accessor :node, :bag, :secret_file, :one_item_passwords

    def initialize(node, bag = "passwords")
      @node = node
      @bag = bag
      @secret_file = node["percona"]["encrypted_data_bag_secret_file"]
      item_name = node["percona"]["single_bag_name"]
	  if item_name.to_s.length > 0 then
		it_name = item_name
		Chef::Log.info("All passwords will be retrieved from item: #{it_name}")
		# load the encrypted data bag item, using a secret if specified
		@one_item_passwords = Chef::EncryptedDataBagItem.load(@bag, it_name, data_bag_secret)
	  end
    end

    # helper for passwords
    def find_password(item, user, default = nil)
		begin
			Chef::Log.info("Looking for #{user} password in #{item} ")
			# let's look for the user password in the single data bag item
			password = @one_item_passwords[item][user]
		rescue
			begin
				Chef::Log.info("Not found in single item, Looking for #{user} password in item #{item} ")
				# load the encrypted data bag item, using a secret if specified
				@passwords = Chef::EncryptedDataBagItem.load(@bag, item, data_bag_secret)
				# now, let's look for the user password
				password = passwords[user]
			rescue
				Chef::Log.info("Using non-encrypted password for #{user}, #{item}")
			end
		end
		# password will be nil if no encrypted data bag was loaded
		# fall back to the attribute on this node
		password || default
    end

    # mysql root
    def root_password
      find_password "mysql", "root", node_server["root_password"]
    end

    # debian script user password
    def debian_password
      find_password(
        "system", node_server["debian_username"], node_server["debian_password"]
      )
    end

    # ?
    def old_passwords
      find_password "mysql", "old_passwords", node_server["old_passwords"]
    end

    # password for user responsbile for replicating in master/slave environment
    def replication_password
      find_password(
        "mysql", "replication", node_server["replication"]["password"]
      )
    end

    # password for user responsbile for running xtrabackup
    def backup_password
      backup = node["percona"]["backup"]
      find_password "mysql", backup["username"], backup["password"]
    end

    private

    # helper
    def node_server
      @node["percona"]["server"]
    end

    def data_bag_secret_file
      if !secret_file.empty? && ::File.exist?(secret_file)
        secret_file
	  # File not found or inaccessible
      elsif !Chef::Config[:encrypted_data_bag_secret].empty?
        Chef::Config[:encrypted_data_bag_secret]
      end
    end

    def data_bag_secret
      return unless data_bag_secret_file

      Chef::EncryptedDataBagItem.load_secret(data_bag_secret_file)
    end
  end
end
