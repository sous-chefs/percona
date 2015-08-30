require "spec_helper"

describe "percona::cluster" do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  before do
    stub_command("test -f /var/lib/mysql/mysql/user.frm").and_return(true)
    stub_command("mysqladmin --user=root --password='' version")
      .and_return(true)
  end

  specify do
    expect(chef_run).to include_recipe "percona::package_repo"
    expect(chef_run).to include_recipe "percona::configure_server"
    expect(chef_run).to include_recipe "percona::access_grants"

    expect(chef_run).to_not include_recipe "yum-epel"
  end

  describe "version 5.5" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set["percona"]["version"] = "5.5"
      end.converge(described_recipe)
    end

    let(:centos_cluster_package) do
      "Percona-XtraDB-Cluster-55"
    end

    let(:ubuntu_cluster_package) do
      "percona-xtradb-cluster-55"
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
        ChefSpec::SoloRunner.new(env_options) do |node|
          node.set["percona"]["version"] = "5.5"
        end.converge(described_recipe)
      end

      before do
        stub_command("rpm -qa | grep -q 'Percona-XtraDB-Cluster-55'")
          .and_return(false)
      end

      specify do
        expect(chef_run).to remove_package "mysql-libs"

        expect(chef_run).to include_recipe "yum-epel"

        expect(chef_run).to install_package centos_cluster_package
      end
    end
  end

  describe "version 5.6" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set["percona"]["version"] = "5.6"
      end.converge(described_recipe)
    end

    let(:centos_cluster_package) do
      "Percona-XtraDB-Cluster-56"
    end

    let(:ubuntu_cluster_package) do
      "percona-xtradb-cluster-56"
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
        ChefSpec::SoloRunner.new(env_options) do |node|
          node.set["percona"]["version"] = "5.6"
        end.converge(described_recipe)
      end

      before do
        stub_command("rpm -qa | grep -q 'Percona-XtraDB-Cluster-56'")
          .and_return(false)
      end

      specify do
        expect(chef_run).to remove_package "mysql-libs"

        expect(chef_run).to include_recipe "yum-epel"

        expect(chef_run).to install_package centos_cluster_package
      end
    end
  end
end
