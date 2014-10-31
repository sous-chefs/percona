require "spec_helper"

describe "percona::pam_auth" do
  let(:mysqld_file) do
    "/etc/pam.d/mysqld"
  end

  let(:pam_auth_sql_file) do
    "/etc/mysql/pam_auth.sql"
  end

  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it "writes the `mysqld` file" do
    expect(chef_run).to create_cookbook_file_if_missing(mysqld_file).with(
      owner: "root",
      group: "root",
      mode: "0644"
    )
  end

  it "writes the `pam_auth.sql` file" do
    expect(chef_run).to create_cookbook_file_if_missing(pam_auth_sql_file).with(
      owner: "root",
      group: "root",
      mode: "0600"
    )
  end

  it "executes the `install pam_auth` command" do
    expect(chef_run).to_not run_execute("mysql-install-pam_auth")

    exec_resource = chef_run.execute("mysql-install-pam_auth")
    expect(exec_resource).to(
      subscribe_to("cookbook_file[#{pam_auth_sql_file}]").on(:run).immediately
    )

    tmpl_resource = chef_run.cookbook_file(pam_auth_sql_file)
    expect(tmpl_resource).to(
      notify("execute[mysql-install-pam_auth]").to(:run).immediately
    )
  end
end
