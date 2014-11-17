require "spec_helper"

describe "percona::cluster" do
  let(:centos_cluster_package) do
    "Percona-XtraDB-Cluster-55"
  end

  let(:ubuntu_cluster_package) do
    "percona-xtradb-cluster-55"
  end

  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  before do
    stub_command("test -f /var/lib/mysql/mysql/user.frm").and_return(true)
    stub_command("test -f /etc/mysql/grants.sql").and_return(true)
  end

  specify do
    expect(chef_run).to include_recipe("percona::package_repo")
    expect(chef_run).to include_recipe("percona::configure_server")
    expect(chef_run).to include_recipe("percona::access_grants")
  end

  describe "Ubuntu" do
    specify do
      expect(chef_run).to install_package(ubuntu_cluster_package)

      expect(chef_run.package(ubuntu_cluster_package)).to(
        notify("service[mysql]").to(:stop).immediately
      )
    end
  end

  describe "CentOS" do
    let(:chef_run) do
      env_options = { platform: "centos", version: "6.5" }
      ChefSpec::SoloRunner.new(env_options).converge(described_recipe)
    end

    specify do
      expect(chef_run).to remove_package("mysql-libs")
      expect(chef_run).to install_package(centos_cluster_package)
    end
  end
end
