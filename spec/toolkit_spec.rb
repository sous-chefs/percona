require "spec_helper"

describe "percona::toolkit" do
  let(:centos_package) do
    "Percona-Server-shared-compat"
  end

  let(:ubuntu_package) do
    "percona-toolkit"
  end

  describe "Ubuntu" do
    let(:chef_run) do
      ChefSpec::Runner.new.converge(described_recipe)
    end

    it { expect(chef_run).to_not install_package(centos_package) }
    it { expect(chef_run).to install_package(ubuntu_package) }
  end

  describe "CentOS" do

    describe "when `version` is 5.5" do
      let(:chef_run) do
        env_options = { platform: "centos", version: "6.5" }
        ChefSpec::Runner.new(env_options) do |node|
          node.set["percona"]["version"] = "5.5"
        end.converge(described_recipe)
      end

      it { expect(chef_run).to install_package(centos_package) }
      it { expect(chef_run).to install_package(ubuntu_package) }
  
    end

    describe "when `version` is 5.6" do
      let(:chef_run) do
        env_options = { platform: "centos", version: "6.5" }
        ChefSpec::Runner.new(env_options) do |node|
          node.set["percona"]["version"] = "5.6"
        end.converge(described_recipe)
      end

      it { expect(chef_run).to_not install_package(centos_package) }
      it { expect(chef_run).to install_package(ubuntu_package) }
  
    end

  end
end
