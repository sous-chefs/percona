#
# Cookbook Name:: percona
# Recipe:: ssl
#

certs_path = '/etc/mysql/ssl'
server = node["percona"]["server"]

directory certs_path do
  action :create
  owner node.percona.server.username
  mode 0700
end

certs = Chef::EncryptedDataBagItem.load(node["percona"]["encrypted_data_bag"], 'ssl_replication')

# place the CA certificate, it should be present on both master and slave
file "#{certs_path}/cacert.pem" do
  content certs['ca-cert']
end

%w(cert key).each do |file|
  # place certificate and key for master
  if server["role"].include?('master')
    file "#{certs_path}/server-#{file}.pem" do
      content certs['server']["server-#{file}"]
    end
  end
  # because in a master-master setup a slave could also be a master, we don't use else here
  # place slave certificate and key
  if server["role"].include?('slave')
    file "#{certs_path}/client-#{file}.pem" do
      content certs['client']["client-#{file}"]
    end
  end
end