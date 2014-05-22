require "spec_helper"

describe "percona::default" do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it { expect(chef_run).to include_recipe("percona::client") }
end
