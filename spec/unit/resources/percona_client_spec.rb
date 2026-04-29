# frozen_string_literal: true

require 'spec_helper'

describe 'percona_client' do
  step_into :percona_client
  platform 'ubuntu', '24.04'

  recipe do
    percona_client 'default' do
      install_devel_package true
    end
  end

  it { is_expected.to install_package('percona client packages').with(package_name: %w(percona-server-client libperconaserverclient22-dev)) }
end
