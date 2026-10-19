# frozen_string_literal: true

require 'spec_helper'

describe 'percona_mysql_database' do
  platform 'ubuntu', '24.04'

  recipe do
    percona_mysql_database 'app' do
      password ''
    end
  end

  it { is_expected.to create_percona_mysql_database('app') }
end
