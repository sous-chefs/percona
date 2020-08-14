require 'spec_helper'

describe 'percona::access_grants' do
  platform 'ubuntu'

  let(:grant_file) do
    '/etc/mysql/grants.sql'
  end

  override_attributes['percona']['server']['root_password'] = 's3kr1t'
  override_attributes['percona']['server']['debian_password'] = 's3kr1t'
  override_attributes['percona']['backup']['password'] = 's3kr1t'

  it 'writes the `grants.sql` file' do
    expect(chef_run).to create_template(grant_file).with(
      owner: 'root',
      group: 'root',
      mode: '0600',
      sensitive: true,
      variables: {
        root_password: 's3kr1t',
        debian_password: 's3kr1t',
        backup_password: 's3kr1t',
        debian_user: 'debian-sys-maint',
      }
    )
  end

  it 'adds the root password to `grants.sql`' do
    expect(chef_run).to render_file(grant_file).with_content(
      "ALTER USER 'root'@'localhost' IDENTIFIED BY 's3kr1t';"
    )
  end

  context 'Percona < 8.0' do
    override_attributes['percona']['version'] = '5.7'
    override_attributes['percona']['server']['root_password'] = 's3kr1t'
    it 'adds the root password to `grants.sql`' do
      expect(chef_run).to render_file(grant_file).with_content(
        "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('s3kr1t');"
      )
    end
  end

  it 'executes the `install privileges` command' do
    expect(chef_run).to nothing_execute('mysql-install-privileges')
      .with(command: "/usr/bin/mysql -p's3kr1t' -e '' &> /dev/null > /dev/null &> /dev/null ; if [ $? -eq 0 ] ; then /usr/bin/mysql -p's3kr1t' < /etc/mysql/grants.sql ; else /usr/bin/mysql < /etc/mysql/grants.sql ; fi ;")

    exec_resource = chef_run.execute('mysql-install-privileges')
    expect(exec_resource).to(
      subscribe_to("template[#{grant_file}]").on(:run).immediately
    )

    tmpl_resource = chef_run.template(grant_file)
    expect(tmpl_resource).to(
      notify('execute[mysql-install-privileges]').to(:run).immediately
    )
  end
end
