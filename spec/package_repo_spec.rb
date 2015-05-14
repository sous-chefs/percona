require "spec_helper"

describe "percona::package_repo" do
  describe "Ubuntu" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it "sets up an apt repository for `percona`" do
      expect(chef_run).to add_apt_repository("percona")
    end

    it "sets up an apt preference" do
      expect(chef_run).to add_apt_preference("00percona")
    end
  end

  describe "CentOS" do
    let(:chef_run) do
      env_options = { platform: "centos", version: "6.5" }
      ChefSpec::SoloRunner.new(env_options).converge(described_recipe)
    end

    it "sets up a yum repository for `percona`" do
      expect(chef_run).to create_yum_repository("percona")
    end
  end
end
