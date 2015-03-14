require "spec_helper"

describe "percona::server" do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  before do
    stub_command("test -f /var/lib/mysql/mysql/user.frm").and_return(true)
    stub_command("mysqladmin --user=root --password='' version")
      .and_return(true)
  end

  it { expect(chef_run).to include_recipe("percona::package_repo") }
  it { expect(chef_run).to include_recipe("percona::configure_server") }
  it { expect(chef_run).to include_recipe("percona::access_grants") }
  it { expect(chef_run).to include_recipe("percona::replication") }

  describe "Ubuntu" do
    it { expect(chef_run).to install_package("percona-server-server-5.6") }
  end

  describe "CentOS" do
    let(:shared_pkg) do
      "Percona-Server-shared-56"
    end

    let(:chef_run) do
      env_options = { platform: "centos", version: "6.5" }
      ChefSpec::SoloRunner.new(env_options).converge(described_recipe)
    end

    before do
      stub_command("rpm -qa | grep #{shared_pkg}").and_return(false)
    end

    describe "without percona server shared package" do
      it { expect(chef_run).to remove_package("mysql-libs") }
    end

    describe "with percona server shared package" do
      before do
        stub_command("rpm -qa | grep #{shared_pkg}").and_return(true)
      end

      it { expect(chef_run).to_not remove_package("mysql-libs") }
    end

    it { expect(chef_run).to include_recipe("percona::client") }
    it { expect(chef_run).to install_package("Percona-Server-server-56") }
  end

  describe "when `skip_configure` is true" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set["percona"]["skip_configure"] = true
      end.converge(described_recipe)
    end

    it { expect(chef_run).to_not include_recipe("percona::configure_server") }
  end

  describe "when `skip_passwords` is true" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set["percona"]["skip_passwords"] = true
      end.converge(described_recipe)
    end

    it { expect(chef_run).to_not include_recipe("percona::access_grants") }
    it { expect(chef_run).to_not include_recipe("percona::replication") }
  end

  describe "when `package_action` is `upgrade`" do
    describe "Ubuntu" do
      let(:chef_run) do
        ChefSpec::SoloRunner.new do |node|
          node.set["percona"]["server"]["package_action"] = "upgrade"
        end.converge(described_recipe)
      end

      it { expect(chef_run).to upgrade_package("percona-server-server-5.6") }
    end

    describe "CentOS" do
      let(:chef_run) do
        env_options = { platform: "centos", version: "6.5" }
        ChefSpec::SoloRunner.new(env_options) do |node|
          node.set["percona"]["server"]["package_action"] = "upgrade"
        end.converge(described_recipe)
      end

      before do
        stub_command("rpm -qa | grep Percona-Server-shared-56")
          .and_return(false)
      end

      it { expect(chef_run).to upgrade_package("Percona-Server-server-56") }
    end
  end
end
