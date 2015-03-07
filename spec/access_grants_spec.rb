require "spec_helper"

describe "percona::access_grants" do
  let(:grant_file) do
    "/etc/mysql/grants.sql"
  end

  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set["percona"]["server"]["root_password"] = "s3kr1t"
    end.converge(described_recipe)
  end

  it "writes the `grants.sql` file" do
    expect(chef_run).to create_template(grant_file).with(
      owner: "root",
      group: "root",
      mode: "0600",
      sensitive: true
    )
  end

  it "adds the root password to `grants.sql`" do
    expect(chef_run).to render_file(grant_file).with_content(
      "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('s3kr1t')"
    )
  end

  it "executes the `install privileges` command" do
    expect(chef_run).to_not run_execute("mysql-install-privileges")

    exec_resource = chef_run.execute("mysql-install-privileges")
    expect(exec_resource).to(
      subscribe_to("template[#{grant_file}]").on(:run).immediately
    )

    tmpl_resource = chef_run.template(grant_file)
    expect(tmpl_resource).to(
      notify("execute[mysql-install-privileges]").to(:run).immediately
    )
  end
end
