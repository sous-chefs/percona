#
# Cookbook:: percona
# Recipe:: ssl
#

certs_path = '/etc/mysql/ssl'
server = node['percona']['server']
data_bag = node['percona']['encrypted_data_bag']

directory certs_path do
  owner node['percona']['server']['username']
  mode '0700'
end

certs = data_bag_item(
  data_bag,
  node['percona']['encrypted_data_bag_item_ssl_replication']
)

# place the CA certificate, it should be present on both source and replica
file "#{certs_path}/cacert.pem" do
  content certs['ca-cert']
  sensitive true
end

%w(cert key).each do |file|
  # place certificate and key for source
  file "#{certs_path}/server-#{file}.pem" do
    content certs['server']["server-#{file}"]
    sensitive true
    only_if { server['role'].include?('source') || server['role'].include?('master') }
  end

  # because in a source-source setup a source could also be a replica
  # place replica certificate and key
  file "#{certs_path}/client-#{file}.pem" do
    content certs['client']["client-#{file}"]
    sensitive true
    only_if { server['role'].include?('replica') || server['role'].include?('slave') }
  end
end
