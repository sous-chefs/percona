#
# Cookbook Name:: percona
# Attributes:: default
#
# Author:: Phil Cohen <github@phlippers.net>
#
# Copyright 2011, Phil Cohen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

# Always restart percona on configuration changes
default["percona"]["auto_restart"] = true

# Cookbook Settings
default["percona"]["main_config_file"]                          = "/etc/my.cnf"
default["percona"]["keyserver"]                                 = "keys.gnupg.net"
default["percona"]["encrypted_data_bag"]                        = "passwords"

# XtraBackup Settings
default["percona"]["backup"]["configure"]                       = false
default["percona"]["backup"]["username"]                        = "backup"
unless defined?(node["percona"]["backup"]["password"])
  default["percona"]["backup"]["password"]                      = secure_password
end

# XtraDB Cluster Settings
default["percona"]["cluster"]["binlog_format"]                  = "ROW"
default["percona"]["cluster"]["wsrep_provider"]                 = "/usr/lib64/libgalera_smm.so"
default["percona"]["cluster"]["wsrep_cluster_address"]          = ""
default["percona"]["cluster"]["wsrep_slave_threads"]            = 2
default["percona"]["cluster"]["wsrep_cluster_name"]             = ""
default["percona"]["cluster"]["wsrep_sst_method"]               = "rsync"
default["percona"]["cluster"]["wsrep_node_name"]                = ""
default["percona"]["cluster"]["innodb_locks_unsafe_for_binlog"] = 1
default["percona"]["cluster"]["innodb_autoinc_lock_mode"]       = 2
