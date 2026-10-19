# frozen_string_literal: true

require 'spec_helper'

describe 'percona_mysql_user' do
  platform 'ubuntu', '24.04'

  recipe do
    percona_mysql_user 'app' do
      ctrl_password ''
    end
  end

  it { is_expected.to create_percona_mysql_user('app') }
end
