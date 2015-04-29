require "spec_helper"

describe "percona::configure_server" do
  describe "first run" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    before do
      stub_command("test -f /var/lib/mysql/mysql/user.frm").and_return(false)
      stub_command("mysqladmin --user=root --password='' version")
        .and_return(true)
    end

    it "does not include the `chef-vault` recipe" do
      expect(chef_run).to_not include_recipe "chef-vault"
    end

    it "creates the main server config file" do
      expect(chef_run).to create_template("/etc/mysql/my.cnf").with(
        owner: "root",
        group: "root",
        mode: "0644"
      )

      expect(chef_run).to render_file("/etc/mysql/my.cnf").with_content(
        "performance_schema=OFF"
      )

      resource = chef_run.template("/etc/mysql/my.cnf")
      expect(resource).to notify("execute[setup mysql datadir]").to(:run).immediately  # rubocop:disable LineLength
      expect(resource).to notify("service[mysql]").to(:restart).immediately
    end

    it "creates the data directory" do
      expect(chef_run).to create_directory("/var/lib/mysql").with(
        owner: "mysql",
        group: "mysql",
        recursive: true
      )
    end

    it "defines the setup for the data directory" do
      resource = chef_run.execute("setup mysql datadir")
      expect(resource).to do_nothing
    end

    it "creates the log directory" do
      expect(chef_run).to create_directory("/var/log/mysql").with(
        owner: "mysql",
        group: "mysql",
        recursive: true
      )
    end

    it "creates the temporary directory" do
      expect(chef_run).to create_directory("/tmp").with(
        owner: "mysql",
        group: "mysql",
        recursive: true
      )
    end

    it "creates the configuration include directory" do
      expect(chef_run).to create_directory("/etc/mysql/conf.d/").with(
        owner: "mysql",
        group: "mysql",
        recursive: true
      )
    end

    it "updates the root user password" do
      expect(chef_run).to run_execute("Update MySQL root password")
    end
  end

  describe "subsequent runs" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set["percona"]["main_config_file"] = "/mysql/my.cnf"
        node.set["percona"]["server"]["root_password"] = "s3kr1t"
        node.set["percona"]["server"]["debian_password"] = "d3b1an"
        node.set["percona"]["server"]["performance_schema"] = true
        node.set["percona"]["conf"]["mysqld"]["datadir"] = "/mysql/data"
        node.set["percona"]["conf"]["mysqld"]["tmpdir"] = "/mysql/tmp"
        node.set["percona"]["conf"]["mysqld"]["includedir"] = "/mysql/conf.d"
      end.converge(described_recipe)
    end

    before do
      stub_command("test -f /mysql/data/mysql/user.frm").and_return(true)
      stub_command("mysqladmin --user=root --password='' version")
        .and_return(false)
    end

    it "creates a `.my.cnf` file for root" do
      expect(chef_run).to create_template("/root/.my.cnf").with(
        owner: "root",
        group: "root",
        mode: "0600",
        sensitive: true
      )

      expect(chef_run).to render_file("/root/.my.cnf").with_content("s3kr1t")
    end

    it "creates the configuration directory" do
      expect(chef_run).to create_directory("/etc/mysql").with(
        owner: "root",
        group: "root",
        mode: "0755"
      )
    end

    it "creates the data directory" do
      expect(chef_run).to create_directory("/mysql/data").with(
        owner: "mysql",
        group: "mysql",
        recursive: true
      )
    end

    it "creates the temporary directory" do
      expect(chef_run).to create_directory("/mysql/tmp").with(
        owner: "mysql",
        group: "mysql",
        recursive: true
      )
    end

    it "creates the configuration include directory" do
      expect(chef_run).to create_directory("/mysql/conf.d").with(
        owner: "mysql",
        group: "mysql",
        recursive: true
      )
    end

    it "creates the slow query log directory" do
      expect(chef_run).to create_directory("/var/log/mysql").with(
        owner: "mysql",
        group: "mysql",
        recursive: true
      )
    end

    it "manages the `mysql` service" do
      expect(chef_run).to enable_service("mysql")
    end

    it "defines the setup for the data directory" do
      resource = chef_run.execute("setup mysql datadir")
      expect(resource).to do_nothing
    end

    it "creates the main server config file" do
      expect(chef_run).to create_template("/mysql/my.cnf").with(
        owner: "root",
        group: "root",
        mode: "0644",
        sensitive: true
      )

      expect(chef_run).to render_file("/mysql/my.cnf").with_content(
        "performance_schema=ON"
      )

      resource = chef_run.template("/mysql/my.cnf")
      expect(resource).to notify("execute[setup mysql datadir]").to(:run).immediately # rubocop:disable LineLength
      expect(resource).to notify("service[mysql]").to(:restart).immediately
    end

    it "does not update the root user password" do
      expect(chef_run).to_not run_execute("Update MySQL root password")
    end

    it "creates the debian system user config file" do
      debian_cnf = "/etc/mysql/debian.cnf"

      expect(chef_run).to create_template(debian_cnf).with(
        owner: "root",
        group: "root",
        mode: "0640",
        sensitive: true
      )

      expect(chef_run).to render_file(debian_cnf).with_content("d3b1an")

      resource = chef_run.template(debian_cnf)
      expect(resource).to notify("service[mysql]").to(:restart).immediately
    end
  end

  describe "custom slow query log directory" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set["percona"]["server"]["slow_query_logdir"] = "/var/log/slowq"
      end.converge(described_recipe)
    end

    before do
      stub_command("mysqladmin --user=root --password='' version")
        .and_return(true)
    end

    it "creates the slow query log directory" do
      expect(chef_run).to create_directory("/var/log/slowq").with(
        owner: "mysql",
        group: "mysql",
        recursive: true
      )
    end
  end

  describe "`rhel` platform family" do
    let(:chef_run) do
      env_options = { platform: "centos", version: "6.5" }
      ChefSpec::SoloRunner.new(env_options).converge(described_recipe)
    end

    before do
      stub_command("test -f /var/lib/mysql/mysql/user.frm").and_return(false)
      stub_command("mysqladmin --user=root --password='' version")
        .and_return(true)
    end

    it "creates the main server config file" do
      expect(chef_run).to create_template("/etc/my.cnf").with(
        owner: "root",
        group: "root",
        mode: "0644",
        sensitive: true
      )

      resource = chef_run.template("/etc/my.cnf")
      expect(resource).to notify("execute[setup mysql datadir]").to(:run).immediately # rubocop:disable LineLength
      expect(resource).to notify("service[mysql]").to(:restart).immediately
    end

    it "does not create the configuration include directory" do
      expect(chef_run).to_not create_directory("/mysql/conf.d")
    end
  end

  describe "`chef-vault` support" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set["percona"]["use_chef_vault"] = true
      end.converge(described_recipe)
    end

    before do
      stub_command("mysqladmin --user=root --password='' version")
        .and_return(false)
    end

    it "includes the `chef-vault` recipe" do
      expect(chef_run).to include_recipe "chef-vault"
    end
  end
end
