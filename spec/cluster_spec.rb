require "spec_helper"

describe "percona::cluster" do
  let(:cluster_package) do
    "percona-xtradb-cluster-55"
  end

  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  before do
    stub_command("test -f /var/lib/mysql/mysql/user.frm").and_return(true)
    stub_command("test -f /etc/mysql/grants.sql").and_return(true)
  end

  it { expect(chef_run).to include_recipe("percona::package_repo") }
  it { expect(chef_run).to include_recipe("percona::configure_server") }
  it { expect(chef_run).to include_recipe("percona::access_grants") }

  describe "Ubuntu" do
    it { expect(chef_run).to install_package(cluster_package) }

    it "stops the `mysql` service" do
      resource = chef_run.package(cluster_package)
      expect(resource).to notify("service[mysql]").to(:stop).immediately
    end
  end

  describe "CentOS" do
    let(:chef_run) do
      env_options = { platform: "centos", version: "6.5" }
      ChefSpec::Runner.new(env_options).converge(described_recipe)
    end

    it { expect(chef_run).to remove_package("mysql-libs") }
    it { expect(chef_run).to install_package(cluster_package) }
  end
end
