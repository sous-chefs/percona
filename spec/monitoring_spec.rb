require "spec_helper"

describe "percona::monitoring" do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it { expect(chef_run).to install_package("percona-nagios-plugins") }
  it { expect(chef_run).to install_package("percona-zabbix-templates") }
  it { expect(chef_run).to install_package("percona-cacti-templates") }
end
