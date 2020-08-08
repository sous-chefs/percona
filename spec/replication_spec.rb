require 'spec_helper'

describe 'percona::replication' do
  platform 'ubuntu'
  let(:replication_sql) do
    '/etc/mysql/replication.sql'
  end

  describe 'without replication configured' do
    override_attributes['percona']['server']['role'] = []
    override_attributes['percona']['server']['replication']['host'] = ''

    it 'does not create a replication template' do
      expect(chef_run).to_not create_template(replication_sql)
    end

    it 'does not execute the replication sql' do
      expect(chef_run).to_not run_execute('mysql-set-replication')

      resource = chef_run.execute('mysql-set-replication')
      expect(resource).to do_nothing
    end
  end

  describe 'with replication configured' do
    override_attributes['percona']['server']['role'] = ['master']
    override_attributes['percona']['server']['replication']['password'] = 's3kr1t'
    override_attributes['percona']['server']['root_password'] = 's3kr1t'

    it 'creates a replication template' do
      expect(chef_run).to create_template(replication_sql).with(
        owner: 'root',
        group: 'root',
        mode: '0600',
        sensitive: true
      )
      expect(chef_run).to render_file(replication_sql).with_content('s3kr1t')
    end

    it 'executes the replication sql' do
      resource = chef_run.execute('mysql-set-replication')
      expect(chef_run).to nothing_execute('mysql-set-replication').with(
        command: '/usr/bin/mysql -ps3kr1t < /etc/mysql/replication.sql',
        sensitive: true
      )
      expect(resource).to(
        subscribe_to("template[#{replication_sql}]").on(:run).immediately
      )
    end
  end
end
