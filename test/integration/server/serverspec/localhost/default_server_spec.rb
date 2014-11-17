require "serverspec"

set :backend, :exec

def ubuntu?
  os[:family] == "ubuntu"
end

def redhat?
  os[:family] == "redhat"
end

describe "Package installation" do
  specify do
    if ubuntu?
      expect(package "percona-server-server-5.6").to be_installed
      expect(package "libjemalloc1").to be_installed
    elsif redhat?
      expect(package "Percona-Server-devel-56").to be_installed
      expect(package "Percona-Server-client-56").to be_installed
      expect(package "Percona-Server-server-56").to be_installed
      expect(package "jemalloc").to be_installed
    end
  end
end

describe "Service configuration" do
  describe file("/root/.my.cnf") do
    it { should be_a_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into "root" }
    it { should be_mode 600 }
    its(:content) { should match "r00t" }
  end

  describe file("/etc/mysql") do
    it { should be_a_directory }
    it { should be_owned_by "root" }
    it { should be_grouped_into "root" }
    it { should be_mode 755 }
  end

  describe file("/var/lib/mysql") do
    it { should be_a_directory }
    it { should be_owned_by "mysql" }
    it { should be_grouped_into "mysql" }
  end

  describe file("/var/log/mysql") do
    it { should be_a_directory }
    it { should be_owned_by "mysql" }
    it { should be_grouped_into "mysql" }
  end

  describe file("/tmp") do
    it { should be_a_directory }
    it { should be_owned_by "mysql" }
    it { should be_grouped_into "mysql" }
  end

  describe service("mysql") do
    it { should be_enabled }
    it { should be_running }
  end

  describe command("pgrep mysql") do
    its(:stdout) { should match(/\d+/) }
    its(:exit_status) { should eq 0 }
  end

  describe port(3306) do
    it { should be_listening }
  end

  describe file("/var/lib/mysql/mysql/user.frm") do
    it { should be_a_file }
    it { should be_owned_by "mysql" }
    it { should be_grouped_into "mysql" }
  end

  describe file("/etc/mysql/my.cnf"), if: ubuntu? do
    it { should be_a_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into "root" }
    it { should be_mode 644 }
  end

  describe file("/etc/my.cnf"), if: redhat? do
    it { should be_a_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into "root" }
    it { should be_mode 644 }
  end

  describe file("/etc/mysql/grants.sql") do
    it { should be_a_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into "root" }
    it { should be_mode 600 }
    its(:content) { should match "r00t" }
  end

  describe file("/etc/mysql/grants.sql"), if: ubuntu? do
    its(:content) { should match "debian-sys-maint" }
    its(:content) { should match "d3b1an" }
  end

  describe file("/etc/mysql/debian.cnf"), if: ubuntu? do
    it { should be_a_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into "root" }
    it { should be_mode 640 }
    its(:content) { should match "d3b1an" }
  end

  describe file("/etc/mysql/replication.sql") do
    it { should_not be_a_file }
  end
end
