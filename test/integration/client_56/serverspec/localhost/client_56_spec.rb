require "serverspec"

set :backend, :exec

def ubuntu?
  os[:family] == "ubuntu"
end

def redhat?
  os[:family] == "redhat"
end

describe "Ubuntu package installation" do
  describe file("/etc/apt/sources.list.d/percona.list"), if: ubuntu? do
    it { should be_a_file }
    its(:content) { should match "http://repo.percona.com/apt" }
  end

  describe file("/etc/apt/preferences.d/00percona.pref"), if: ubuntu? do
    it { should be_a_file }
    its(:content) { should match "release o=Percona Development Team" }
  end

  describe package("libperconaserverclient18.1-dev"), if: ubuntu? do
    it { should be_installed }
  end

  describe package("percona-server-client-5.6"), if: ubuntu? do
    it { should be_installed }
  end

  describe package("percona-toolkit") do
    it { should be_installed }
  end
end

describe "Red Hat package installation" do
  describe yumrepo("percona"), if: redhat? do
    it { should exist }
    it { should be_enabled }
  end

  describe package("Percona-Server-devel-56"), if: redhat? do
    it { should be_installed }
  end

  describe package("Percona-Server-client-56"), if: redhat? do
    it { should be_installed }
  end

  describe package("percona-toolkit") do
    it { should be_installed }
  end
end
