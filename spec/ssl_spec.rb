require "spec_helper"

describe "percona::ssl" do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set["percona"]["encrypted_data_bag"] = "test-bag"
      node.set["percona"]["server"]["role"] = %w[master slave]
    end.converge(described_recipe)
  end

  before do
    expect(Chef::EncryptedDataBagItem).to(
      receive(:load).with("test-bag", "ssl_replication").and_return(
        "ca-cert" => "test-ca-cert",
        "client" => {
          "client-cert" => "test-client-cert",
          "client-key" => "test-client-key"
        },
        "server" => {
          "server-cert" => "test-server-cert",
          "server-key" => "test-server-key"
        }
      )
    )
  end

  it "creates the certificate directory" do
    expect(chef_run).to create_directory("/etc/mysql/ssl").with(
      user: "mysql",
      mode: "0700"
    )
  end

  it "creates the CA certificate" do
    expect(chef_run).to create_file("/etc/mysql/ssl/cacert.pem").with(
      content: "test-ca-cert",
      sensitive: true
    )
  end

  it "creates the server key" do
    expect(chef_run).to create_file("/etc/mysql/ssl/server-key.pem").with(
      content: "test-server-key",
      sensitive: true
    )
  end

  it "creates the server certificate" do
    expect(chef_run).to create_file("/etc/mysql/ssl/server-cert.pem").with(
      content: "test-server-cert",
      sensitive: true
    )
  end

  it "creates the client key" do
    expect(chef_run).to create_file("/etc/mysql/ssl/client-key.pem").with(
      content: "test-client-key",
      sensitive: true
    )
  end

  it "creates the client certificate" do
    expect(chef_run).to create_file("/etc/mysql/ssl/client-cert.pem").with(
      content: "test-client-cert",
      sensitive: true
    )
  end
end
