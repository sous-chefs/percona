module Percona
  module Cookbook
    module Helpers
      def percona_version
        case node['platform_family']
        when 'debian'
          node['percona']['version']
        when 'rhel'
          node['percona']['version'].tr('.', '')
        end
      end

      def percona_client_packages
        case node['platform_family']
        when 'debian'
          if node['percona']['version'].to_i >= 8
            %w(percona-server-client)
          else
            %W(percona-server-client-#{percona_version})
          end
        when 'rhel'
          if node['percona']['version'].to_i >= 8
            %w(percona-server-client)
          else
            %W(Percona-Server-client-#{percona_version})
          end
        end
      end

      def percona_devel_package
        case node['platform_family']
        when 'rhel'
          if node['percona']['version'].to_i >= 8
            'percona-server-devel'
          else
            "Percona-Server-devel-#{percona_version}"
          end
        when 'debian'
          if node['percona']['version'].to_i >= 8
            'libperconaserverclient21-dev'
          elsif node['percona']['version'] == '5.7'
            'libperconaserverclient20-dev'
          elsif node['percona']['version'] == '5.6'
            'libperconaserverclient18.1-dev'
          end
        end
      end

      def percona_server_package
        if node['percona']['version'].to_i >= 8
          'percona-server-server'
        elsif platform_family?('debian')
          "percona-server-server-#{percona_version}"
        else
          "Percona-Server-server-#{percona_version}"
        end
      end

      def percona_cluster_client_package
        case node['platform_family']
        when 'debian'
          if node['percona']['version'].to_i >= 8
            %w(percona-xtradb-cluster-client)
          else
            %W(percona-xtradb-cluster-client-#{percona_version})
          end
        when 'rhel'
          if node['percona']['version'].to_i >= 8
            %w(percona-xtradb-cluster-client)
          else
            %W(Percona-XtraDB-Cluster-client-#{percona_version})
          end
        end
      end

      def percona_cluster_package
        if node['percona']['version'].to_i >= 8
          'percona-xtradb-cluster-server'
        elsif platform_family?('rhel')
          "Percona-XtraDB-Cluster-#{percona_version}"
        else
          "percona-xtradb-cluster-#{percona_version}"
        end
      end

      def percona_backup_package
        case node['platform_family']
        when 'debian'
          case node['platform']
          when 'debian'
            node['platform_version'].to_i >= 10 ? 'percona-xtrabackup-80' : 'xtrabackup'
          when 'ubuntu'
            node['platform_version'].to_f >= 20.04 ? 'percona-xtrabackup-80' : 'xtrabackup'
          end
        when 'rhel'
          node['platform_version'].to_i >= 8 ? 'percona-xtrabackup-80' : 'percona-xtrabackup'
        end
      end

      def percona_jemalloc_package
        case node['platform']
        when 'debian'
          node['platform_version'].to_i >= 10 ? 'libjemalloc2' : 'libjemalloc1'
        when 'ubuntu'
          node['platform_version'].to_f >= 20.04 ? 'libjemalloc2' : 'libjemalloc1'
        when 'centos', 'redhat', 'almalinux', 'rocky'
          'jemalloc'
        end
      end

      def percona_jemalloc_lib
        case node['platform']
        when 'debian'
          node['platform_version'].to_i >= 10 ? '/usr/lib/x86_64-linux-gnu/libjemalloc.so.2' : '/usr/lib/x86_64-linux-gnu/libjemalloc.so.1'
        when 'ubuntu'
          node['platform_version'].to_f >= 20.04 ? '/usr/lib/x86_64-linux-gnu/libjemalloc.so.2' : '/usr/lib/x86_64-linux-gnu/libjemalloc.so.1'
        when 'centos', 'redhat', 'almalinux', 'rocky'
          node['platform_version'].to_i >= 8 ? '/usr/lib64/libjemalloc.so.2' : '/usr/lib64/libjemalloc.so.1'
        end
      end

      def percona_default_encoding
        node['percona']['version'].to_i >= 8 ? 'utf8mb4' : 'utf8'
      end

      def percona_default_collate
        node['percona']['version'].to_i >= 8 ? 'utf8mb4_0900_ai_ci' : 'utf8_general_ci'
      end

      include Chef::Mixin::ShellOut
      require 'securerandom'
      #######
      # Function to execute an SQL statement
      #   Input:
      #     query : Query could be a single String or an Array of String.
      #     database : a string containing the name of the database to query in, nil if no database choosen
      #     ctrl : a Hash which could contain:
      #        - user : String or nil
      #        - password : String or nil
      #        - host : String or nil
      #        - port : String or Integer or nil
      #        - socket : String or nil
      #   Output: A String with cmd to execute the query (but do not execute it!)
      #
      def sql_command_string(query, database, ctrl, grep_for = nil)
        raw_query = query.is_a?(String) ? query : query.join(";\n")
        Chef::Log.debug("Control Hash: [#{ctrl.to_json}]\n")
        cmd = "/usr/bin/mysql -B -e \"#{raw_query}\""
        cmd << " --user=#{ctrl[:user]}" if ctrl && ctrl.key?(:user) && !ctrl[:user].nil?
        cmd << " -p'#{ctrl[:password]}'" if ctrl && ctrl.key?(:password) && !ctrl[:password].nil?
        cmd << " -h #{ctrl[:host]}"     if ctrl && ctrl.key?(:host) && !ctrl[:host].nil? && ctrl[:host] != 'localhost'
        cmd << " -P #{ctrl[:port]}"     if ctrl && ctrl.key?(:port) && !ctrl[:port].nil? && ctrl[:host] != 'localhost'
        cmd << " -S #{default_socket}"   if ctrl && ctrl.key?(:host) && !ctrl[:host].nil? && ctrl[:host] == 'localhost'
        cmd << " #{database}"            unless database.nil?
        cmd << " | grep #{grep_for}"     if grep_for
        Chef::Log.debug("Executing this command: [#{cmd}]\n")
        cmd
      end

      #######
      # Function to execute an SQL statement in the default database.
      #   Input: Query could be a single String or an Array of String.
      #   Output: A String with <TAB>-separated columns and \n-separated rows.
      # This is easiest for 1-field (1-row, 1-col) results, otherwise
      # it will be complex to parse the results.
      def execute_sql(query, db_name, ctrl)
        cmd = shell_out(sql_command_string(query, db_name, ctrl),
                        user: 'root')
        if cmd.exitstatus != 0
          Chef::Log.fatal("mysql failed executing this SQL statement:\n#{query}")
          Chef::Log.fatal(cmd.stderr)
          raise 'SQL ERROR'
        end
        cmd.stdout
      end

      # Returns status code of sql query
      def execute_sql_exitstatus(query, ctrl)
        shell_out(sql_command_string(query, nil, ctrl), user: 'root').exitstatus
      end

      def parse_one_row(row, titles)
        return_hash = {}
        index = 0
        row.split("\t").each do |column|
          return_hash[titles[index]] = column
          index += 1
        end
        return_hash
      end

      def parse_mysql_batch_result(mysql_batch_result)
        results = mysql_batch_result.split("\n")
        titles = []
        index = 0
        return_array = []
        results.each do |row|
          if index == 0
            titles = row.split("\t")
          else
            return_array[index - 1] = parse_one_row(row, titles)
          end
          index += 1
        end
        return_array
      end

      def default_socket
        case node['platform_family']
        when 'rhel', 'fedora', 'amazon'
          '/var/lib/mysql/mysql.sock'
        when 'debian'
          '/var/run/mysqld/mysqld.sock'
        end
      end

      def percona_secure_random
        r = SecureRandom.hex
        Chef::Log.debug "Generated password: #{r}"
        r
      end
    end
  end
end

Chef::DSL::Recipe.include ::Percona::Cookbook::Helpers
Chef::Resource.include ::Percona::Cookbook::Helpers
