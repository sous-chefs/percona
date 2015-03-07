require "spec_helper"

describe "percona::replication" do
  let(:replication_sql) do
    "/etc/mysql/replication.sql"
  end

  describe "without replication configured" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set["percona"]["server"]["role"] = []
        node.set["percona"]["server"]["replication"]["host"] = ""
      end.converge(described_recipe)
    end

    it "does not create a replication template" do
      expect(chef_run).to_not create_template(replication_sql)
    end

    it "does not execute the replication sql" do
      expect(chef_run).to_not run_execute("mysql-set-replication")

      resource = chef_run.execute("mysql-set-replication")
      expect(resource).to do_nothing
    end
  end

  describe "with replication configured" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set["percona"]["server"]["role"] = ["master"]
        node.set["percona"]["server"]["replication"]["password"] = "s3kr1t"
      end.converge(described_recipe)
    end

    it "creates a replication template" do
      expect(chef_run).to create_template(replication_sql).with(
        owner: "root",
        group: "root",
        mode: "0600",
        sensitive: true
      )
      expect(chef_run).to render_file(replication_sql).with_content("s3kr1t")
    end

    it "executes the replication sql" do
      resource = chef_run.execute("mysql-set-replication")
      expect(resource).to(
        subscribe_to("template[#{replication_sql}]").on(:run).immediately
      )
    end
  end
end
