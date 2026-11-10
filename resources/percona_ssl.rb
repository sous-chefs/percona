# frozen_string_literal: true

provides :percona_ssl
unified_mode true

use '_partial/_config'

property :certs_path, String, default: '/etc/mysql/ssl'
property :certificates, Hash, default: {}
property :server_roles, Array, default: ['standalone']
property :owner, String, default: 'mysql'

action :create do
  directory new_resource.certs_path do
    owner new_resource.owner
    mode '0700'
    recursive true
  end

  file "#{new_resource.certs_path}/cacert.pem" do
    content lazy {
      certs = new_resource.certificates.empty? ? data_bag_item(new_resource.encrypted_data_bag, new_resource.encrypted_data_bag_item_ssl_replication) : new_resource.certificates
      certs['ca-cert']
    }
    sensitive true
  end

  %w(cert key).each do |file_type|
    file "#{new_resource.certs_path}/server-#{file_type}.pem" do
      content lazy {
        certs = new_resource.certificates.empty? ? data_bag_item(new_resource.encrypted_data_bag, new_resource.encrypted_data_bag_item_ssl_replication) : new_resource.certificates
        certs['server']["server-#{file_type}"]
      }
      sensitive true
      only_if { new_resource.server_roles.include?('source') || new_resource.server_roles.include?('master') }
    end

    file "#{new_resource.certs_path}/client-#{file_type}.pem" do
      content lazy {
        certs = new_resource.certificates.empty? ? data_bag_item(new_resource.encrypted_data_bag, new_resource.encrypted_data_bag_item_ssl_replication) : new_resource.certificates
        certs['client']["client-#{file_type}"]
      }
      sensitive true
      only_if { new_resource.server_roles.include?('replica') || new_resource.server_roles.include?('slave') }
    end
  end
end

action :delete do
  %w(
    cacert.pem
    server-cert.pem
    server-key.pem
    client-cert.pem
    client-key.pem
  ).each do |cert_file|
    file ::File.join(new_resource.certs_path, cert_file) do
      action :delete
    end
  end

  directory new_resource.certs_path do
    action :delete
  end
end
