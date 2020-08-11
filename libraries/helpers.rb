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
          if node['percona']['version'].to_f >= 8.0
            %w(percona-server-client)
          else
            %W(percona-server-client-#{percona_version})
          end
        when 'rhel'
          if node['percona']['version'].to_f >= 8.0
            %w(percona-server-client)
          else
            %W(Percona-Server-client-#{percona_version})
          end
        end
      end

      def percona_server_package
        if node['percona']['version'].to_f >= 8.0
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
          if node['percona']['version'].to_f >= 8.0
            %w(percona-xtradb-cluster-client)
          else
            %W(percona-xtradb-cluster-client-#{percona_version})
          end
        when 'rhel'
          if node['percona']['version'].to_f >= 8.0
            %w(percona-xtradb-cluster-client)
          else
            %W(Percona-XtraDB-Cluster-client-#{percona_version})
          end
        end
      end

      def percona_cluster_package
        if node['percona']['version'].to_f >= 8.0
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
        when 'centos', 'redhat'
          'jemalloc'
        end
      end

      def percona_jemalloc_lib
        case node['platform']
        when 'debian'
          node['platform_version'].to_i >= 10 ? '/usr/lib/x86_64-linux-gnu/libjemalloc.so.2' : '/usr/lib/x86_64-linux-gnu/libjemalloc.so.1'
        when 'ubuntu'
          node['platform_version'].to_f >= 20.04 ? '/usr/lib/x86_64-linux-gnu/libjemalloc.so.2' : '/usr/lib/x86_64-linux-gnu/libjemalloc.so.1'
        when 'centos', 'redhat'
          node['platform_version'].to_i >= 8 ? '/usr/lib64/libjemalloc.so.2' : '/usr/lib64/libjemalloc.so.1'
        end
      end
    end
  end
end

Chef::Recipe.include ::Percona::Cookbook::Helpers
Chef::Resource.include ::Percona::Cookbook::Helpers
