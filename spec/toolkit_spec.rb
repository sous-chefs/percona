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
    let(:chef_run) do
      env_options = { platform: "centos", version: "6.5" }
      ChefSpec::Runner.new(env_options).converge(described_recipe)
    end

    it { expect(chef_run).to install_package(centos_package) }
    it { expect(chef_run).to install_package(ubuntu_package) }
  end
end
