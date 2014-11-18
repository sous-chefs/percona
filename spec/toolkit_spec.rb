require "spec_helper"

describe "percona::toolkit" do
  let(:centos_package) do
    "Percona-Server-shared-compat"
  end

  let(:toolkit_package) do
    "percona-toolkit"
  end

  describe "Ubuntu" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    specify do
      expect(chef_run).to_not install_package(centos_package)

      expect(chef_run).to install_package(toolkit_package)
    end
  end

  describe "CentOS" do
    describe "when `version` is 5.5" do
      let(:chef_run) do
        env_options = { platform: "centos", version: "6.5" }
        ChefSpec::SoloRunner.new(env_options) do |node|
          node.set["percona"]["version"] = "5.5"
        end.converge(described_recipe)
      end

      specify do
        expect(chef_run).to install_package(centos_package)
        expect(chef_run).to install_package(toolkit_package)
      end
    end

    describe "when `version` is 5.6" do
      let(:chef_run) do
        env_options = { platform: "centos", version: "6.5" }
        ChefSpec::SoloRunner.new(env_options) do |node|
          node.set["percona"]["version"] = "5.6"
        end.converge(described_recipe)
      end

      specify do
        expect(chef_run).to_not install_package(centos_package)

        expect(chef_run).to install_package(toolkit_package)
      end
    end
  end
end
