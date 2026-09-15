# frozen_string_literal: true

require 'spec_helper'

describe 'percona_cluster' do
  step_into :percona_cluster
  platform 'ubuntu', '24.04'

  recipe do
    percona_cluster 'default' do
      skip_passwords true
    end
  end

  it { is_expected.to install_package('percona cluster package').with(package_name: 'percona-xtradb-cluster-server') }
  it { is_expected.to install_percona_client('percona cluster') }
  it { is_expected.to create_percona_server_config('percona cluster') }
end
