require "spec_helper"

describe "percona::backup" do
  describe "Ubuntu" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it { expect(chef_run).to include_recipe("percona::package_repo") }
    it { expect(chef_run).to install_package("xtrabackup") }
    it { expect(chef_run).to include_recipe("percona::access_grants") }
  end

  describe "CentOS" do
    let(:chef_run) do
      env_options = { platform: "centos", version: "6.5" }
      ChefSpec::SoloRunner.new(env_options).converge(described_recipe)
    end

    it { expect(chef_run).to include_recipe("percona::package_repo") }
    it { expect(chef_run).to install_package("percona-xtrabackup") }
    it { expect(chef_run).to include_recipe("percona::access_grants") }
  end
end
