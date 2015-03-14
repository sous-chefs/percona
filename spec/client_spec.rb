require "spec_helper"

describe "percona::client" do
  describe "when `package_action` is `install`" do
    describe "Ubuntu" do
      let(:chef_run) do
        ChefSpec::SoloRunner.new.converge(described_recipe)
      end

      specify do
        expect(chef_run).to install_package "libperconaserverclient18.1-dev"
        expect(chef_run).to install_package "percona-server-client-5.6"
      end
    end

    describe "CentOS" do
      let(:chef_run) do
        env_options = { platform: "centos", version: "6.5" }
        ChefSpec::SoloRunner.new(env_options).converge(described_recipe)
      end

      specify do
        expect(chef_run).to install_package "Percona-Server-devel-56"
        expect(chef_run).to install_package "Percona-Server-client-56"
      end
    end
  end

  describe "when `package_action` is `upgrade`" do
    describe "Ubuntu" do
      let(:chef_run) do
        ChefSpec::SoloRunner.new do |node|
          node.set["percona"]["client"]["package_action"] = "upgrade"
        end.converge(described_recipe)
      end

      specify do
        expect(chef_run).to upgrade_package "libperconaserverclient18.1-dev"
        expect(chef_run).to upgrade_package "percona-server-client-5.6"
      end
    end

    describe "CentOS" do
      let(:chef_run) do
        env_options = { platform: "centos", version: "6.5" }
        ChefSpec::SoloRunner.new(env_options) do |node|
          node.set["percona"]["client"]["package_action"] = "upgrade"
        end.converge(described_recipe)
      end

      specify do
        expect(chef_run).to upgrade_package "Percona-Server-devel-56"
        expect(chef_run).to upgrade_package "Percona-Server-client-56"
      end
    end
  end
end
