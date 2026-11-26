# frozen_string_literal: true

require 'spec_helper'

describe 'percona_replication' do
  step_into :percona_replication
  platform 'ubuntu', '24.04'

  recipe do
    percona_replication 'default' do
      server_config(
        root_password: 'rootpass',
        role: %w(source),
        replication: {
          host: 'source-host',
          username: 'replication',
          password: 'replpass',
        }
      )
    end
  end

  it { is_expected.to create_template('/etc/mysql/replication.sql') }
  it { is_expected.to nothing_execute('mysql-set-replication') }
end
