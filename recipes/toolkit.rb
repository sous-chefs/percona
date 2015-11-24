#
# Cookbook Name:: percona
# Recipe:: toolkit
#

include_recipe "percona::package_repo"

package "percona-toolkit" do
  options "--force-yes" if platform_family?("debian")
end
