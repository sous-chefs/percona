require "spec_helper"

describe "percona::client" do
  describe "Ubuntu" do
    let(:chef_run) do
      ChefSpec::Runner.new.converge(described_recipe)
    end

    it { expect(chef_run).to install_package("libperconaserverclient18.1-dev") }
    it { expect(chef_run).to install_package("percona-server-client-5.6") }
  end

  describe "CentOS" do
    let(:chef_run) do
      env_options = { platform: "centos", version: "6.5" }
      ChefSpec::Runner.new(env_options).converge(described_recipe)
    end

    it { expect(chef_run).to install_package("Percona-Server-devel-56") }
    it { expect(chef_run).to install_package("Percona-Server-client-56") }
  end
end
