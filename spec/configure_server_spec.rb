require "spec_helper"

describe "percona::configure_server" do
  describe "first run" do
    let(:chef_run) do
      ChefSpec::Runner.new.converge(described_recipe)
    end

    before do
      stub_command("test -f /var/lib/mysql/mysql/user.frm").and_return(false)
      stub_command("test -f /etc/mysql/grants.sql").and_return(false)
    end

    it "creates the main server config file" do
      expect(chef_run).to create_template("/etc/my.cnf").with(
        owner: "root",
        group: "root",
        mode: "0644"
      )

      resource = chef_run.template("/etc/my.cnf")
      expect(resource).to notify("service[mysql]").to(:restart).immediately
    end

    it "creates the data directory" do
      expect(chef_run).to create_directory("/var/lib/mysql").with(
        owner: "mysql",
        group: "mysql",
        recursive: true
      )
    end

    it "sets up the data directory" do
      expect(chef_run).to run_execute("setup mysql datadir")
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

    it "updates the root user password" do
      expect(chef_run).to run_execute("Update MySQL root password")
    end
  end

  describe "subsequent runs" do
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set["percona"]["main_config_file"] = "/mysql/my.cnf"
        node.set["percona"]["server"]["root_password"] = "s3kr1t"
        node.set["percona"]["server"]["debian_password"] = "d3b1an"
        node.set["percona"]["conf"]["mysqld"]["datadir"] = "/mysql/data"
        node.set["percona"]["conf"]["mysqld"]["tmpdir"] = "/mysql/tmp"
      end.converge(described_recipe)
    end

    before do
      stub_command("test -f /mysql/data/mysql/user.frm").and_return(true)
      stub_command("test -f /etc/mysql/grants.sql").and_return(true)
    end

    it "creates a `.my.cnf` file for root" do
      expect(chef_run).to create_template("/root/.my.cnf").with(
        owner: "root",
        group: "root",
        mode: "0600"
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

    it "manages the `mysql` service" do
      expect(chef_run).to enable_service("mysql")
    end

    it "does not setup the data directory" do
      expect(chef_run).to_not run_execute("setup mysql datadir")
    end

    it "creates the main server config file" do
      expect(chef_run).to create_template("/mysql/my.cnf").with(
        owner: "root",
        group: "root",
        mode: "0644"
      )

      resource = chef_run.template("/mysql/my.cnf")
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
        mode: "0640"
      )

      expect(chef_run).to render_file(debian_cnf).with_content("d3b1an")

      resource = chef_run.template(debian_cnf)
      expect(resource).to notify("service[mysql]").to(:restart).immediately
    end
  end
end
