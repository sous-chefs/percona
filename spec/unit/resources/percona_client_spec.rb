# frozen_string_literal: true

require 'spec_helper'

describe 'percona_client' do
  step_into :percona_client

  context 'with the default version' do
    platform 'ubuntu', '24.04'

    recipe do
      percona_client 'default' do
        install_devel_package true
      end
    end

    it { is_expected.to install_package('percona client packages').with(package_name: %w(percona-server-client libperconaserverclient22-dev)) }
  end

  context 'with Percona 8.0' do
    platform 'ubuntu', '24.04'

    recipe do
      percona_client 'default' do
        version '8.0'
        install_devel_package true
      end
    end

    it { is_expected.to install_package('percona client packages').with(package_name: %w(percona-server-client libperconaserverclient21-dev)) }
  end
end
