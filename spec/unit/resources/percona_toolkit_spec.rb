# frozen_string_literal: true

require 'spec_helper'

describe 'percona_toolkit' do
  step_into :percona_toolkit
  platform 'ubuntu', '24.04'

  recipe do
    percona_toolkit 'default'
  end

  it { is_expected.to install_package('percona-toolkit') }
end
