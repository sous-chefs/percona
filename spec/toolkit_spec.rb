require "spec_helper"

describe "percona::toolkit" do
  describe "Ubuntu" do
    let(:chef_run) do
      ChefSpec::Runner.new.converge(described_recipe)
    end

    it { expect(chef_run).to_not install_package("Percona-Server-shared-compat") }
    it { expect(chef_run).to install_package("percona-toolkit") }
  end

  describe "CentOS" do
    let(:chef_run) do
      env_options = { platform: "centos", version: "6.5" }
      ChefSpec::Runner.new(env_options).converge(described_recipe)
    end

    it { expect(chef_run).to install_package("Percona-Server-shared-compat") }
    it { expect(chef_run).to install_package("percona-toolkit") }
  end
end
