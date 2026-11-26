# frozen_string_literal: true

require 'spec_helper'

describe 'percona_toolkit' do
  step_into :percona_toolkit
  platform 'ubuntu', '24.04'

  recipe do
    percona_toolkit 'default'
  end

  it { is_expected.to install_package('percona-toolkit') }

  context 'on AlmaLinux 10' do
    platform 'almalinux', '10'

    it { is_expected.to create_yum_repository('percona-pt').with(baseurl: 'https://repo.percona.com/pt/yum/release/$releasever/RPMS/$basearch') }

    context 'with repository setup managed by the caller' do
      recipe { percona_toolkit('default') { configure_repository false } }

      it { is_expected.not_to create_yum_repository('percona-pt') }
      it { is_expected.to install_package('percona-toolkit') }
    end
  end
end
