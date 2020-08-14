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
    override_attributes['percona']['server']['role'] = %w(source)
    override_attributes['percona']['server']['root_password'] = 's3kr1t'
    override_attributes['percona']['server']['replication']['password'] = 's3kr1t'
    override_attributes['percona']['server']['replication']['username'] = 'replication'
    override_attributes['percona']['server']['replication']['host'] = 'master-host'

    it 'creates a replication template' do
      expect(chef_run).to create_template(replication_sql).with(
        owner: 'root',
        group: 'root',
        mode: '0600',
        sensitive: true
      )
      [
        /CREATE USER IF NOT EXISTS 'replication'@'%' IDENTIFIED BY 's3kr1t';/,
        /GRANT REPLICATION SLAVE ON \*\.\* TO 'replication'@'%';/,
        /MASTER_HOST='master-host'/,
        /MASTER_USER='replication'/,
        /MASTER_PASSWORD='s3kr1t'/,
      ].each do |line|
        expect(chef_run).to render_file(replication_sql).with_content(line)
      end
    end

    context 'role master' do
      override_attributes['percona']['server']['role'] = %w(master)
      it 'creates a replication template' do
        expect(chef_run).to create_template(replication_sql).with(
          owner: 'root',
          group: 'root',
          mode: '0600',
          sensitive: true
        )
        [
          /CREATE USER IF NOT EXISTS 'replication'@'%' IDENTIFIED BY 's3kr1t';/,
          /GRANT REPLICATION SLAVE ON \*\.\* TO 'replication'@'%';/,
          /MASTER_HOST='master-host'/,
          /MASTER_USER='replication'/,
          /MASTER_PASSWORD='s3kr1t'/,
        ].each do |line|
          expect(chef_run).to render_file(replication_sql).with_content(line)
        end
      end
    end

    context 'version 5.7' do
      override_attributes['percona']['version'] = '5.7'
      it do
        [
          /GRANT REPLICATION SLAVE ON \*\.\* TO 'replication'@'%' IDENTIFIED BY 's3kr1t';/,
          /MASTER_HOST='master-host'/,
          /MASTER_USER='replication'/,
          /MASTER_PASSWORD='s3kr1t'/,
        ].each do |line|
          expect(chef_run).to render_file(replication_sql).with_content(line)
        end
      end
    end

    context 'ssl enabled' do
      override_attributes['percona']['server']['replication']['ssl_enabled'] = true
      it do
        [
          /ALTER USER 'replication'@'%' REQUIRE SSL;/,
          /MASTER_SSL=1/,
          %r{MASTER_SSL_CA='/etc/mysql/ssl/cacert.pem'},
          %r{MASTER_SSL_CERT='/etc/mysql/ssl/server-cert.pem'},
          %r{MASTER_SSL_KEY='/etc/mysql/ssl/server-key.pem'},
        ].each do |line|
          expect(chef_run).to render_file(replication_sql).with_content(line)
        end
      end

      context 'version 5.7' do
        override_attributes['percona']['version'] = '5.7'
        it do
          [
            /GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%' IDENTIFIED BY 's3kr1t' REQUIRE SSL;/,
            /MASTER_SSL=1/,
            %r{MASTER_SSL_CA='/etc/mysql/ssl/cacert.pem'},
            %r{MASTER_SSL_CERT='/etc/mysql/ssl/server-cert.pem'},
            %r{MASTER_SSL_KEY='/etc/mysql/ssl/server-key.pem'},
          ].each do |line|
            expect(chef_run).to render_file(replication_sql).with_content(line)
          end
        end
      end

      context 'role replica' do
        override_attributes['percona']['server']['role'] = %w(replica)
        it do
          [
            %r{MASTER_SSL_CERT='/etc/mysql/ssl/client-cert.pem'},
            %r{MASTER_SSL_KEY='/etc/mysql/ssl/client-key.pem'},
          ].each do |line|
            expect(chef_run).to render_file(replication_sql).with_content(line)
          end
        end
      end

      context 'role slave' do
        override_attributes['percona']['server']['role'] = %w(slave)
        it do
          [
            %r{MASTER_SSL_CERT='/etc/mysql/ssl/client-cert.pem'},
            %r{MASTER_SSL_KEY='/etc/mysql/ssl/client-key.pem'},
          ].each do |line|
            expect(chef_run).to render_file(replication_sql).with_content(line)
          end
        end
      end
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
