property :jemalloc, [TrueClass, FalseClass]
property :interface, String
property :username, String
property :slow_query_logdir, String
property :datadir, String
property :logdir. String
property :tmpdir. String
property :includedir, String
property :bind_address, String
property :skip_passwords, String
property :chef_vault, [TrueClass, FalseClass]
property :enable_ssl, [TrueClass, FalseClass]
property :main_config_fail, String
property :auto_restart, [TrueClass, FalseClass]

action :configure do
  percona = node['percona']
  server  = percona['server']
  conf    = percona['conf']

  # setup SELinux if needed
  unless node['percona']['selinux_module_url'].nil? || node['percona']['selinux_module_url'] == ''

    semodule_filename = node['percona']['selinux_module_url'].split('/')[-1]
    semodule_filepath = "#{Chef::Config[:file_cache_path]}/#{semodule_filename}"

    remote_file semodule_filepath do
      source node['percona']['selinux_module_url']
      only_if { semodule_filename && node['platform_family'] == 'rhel' }
    end

    execute "semodule-install-#{semodule_filename}" do
      command "/usr/sbin/semodule -i #{semodule_filepath}"
      only_if { semodule_filename && node['platform_family'] == 'rhel' }
      only_if { shell_out("/usr/sbin/semodule -l | grep '^#{semodule_filename.split('.')[0..-2]}\\s'").stdout == '' }
    end

  end

  include_recipe 'chef-vault' if new_resource.chef_vault

  # construct an encrypted passwords helper -- giving it the node and bag name
  passwords = EncryptedPasswords.new(node, percona['encrypted_data_bag'])

  package_name = value_for_platform_family(
    'debian' => 'libjemalloc1',
    'rhel' => 'jemalloc'
  )

  package package_name do
    only_if { new_resource.jemalloc }
  end

  template '/root/.my.cnf' do
    variables(root_password: passwords.root_password)
    owner 'root'
    group 'root'
    mode '0600'
    source 'my.cnf.root.erb'
    sensitive true
    not_if { new_resource.skip_passwords }
  end

  if new_resource.interface
    ipaddr = Percona::ConfigHelper.bind_to(node, new_resource.interface)
    if ipaddr && new_resource.bind_address != ipaddr
      node.override['percona']['server']['bind_address'] = ipaddr
      node.save unless Chef::Config[:solo]
    end

    log "Can't find ip address for #{new_resource.interface}" do
      level :warn
      only_if { ipaddr.nil? }
    end
  end

  directory 'SQL template directory' do
    path  '/etc/mysql'
    owner 'root'
    group 'root'
    mode '0755'
  end

  directory 'data directory' do
    path  new_resource.datadir
    owner new_resource.user
    group new_resource.user
    recursive true
  end

  directory 'log directory' do
    path  new_resource.logdir
    owner new_resource.user
    group new_resource.user
    recursive true
  end

  directory 'temp directory' do
    path  new_resource.tmpdir
    owner new_resource.user
    group new_resource.user
    recursive true
  end

  directory 'include directory' do
    path  new_resource.includedir
    owner new_resource.user
    group new_resource.user
    recursive true
    not_if { includedir.empty? }
  end

  directory 'slow query log directory' do
    path  new_resource.slow_query_logdir
    owner new_resource.user
    group new_resource.user
    recursive true
    not_if { slow_query_logdir.eql? logdir }
  end

  service 'mysql' do
    supports restart: true
    action :enable
  end

  execute 'setup mysql datadir' do
    command "mysql_install_db --defaults-file=#{new_resource.main_config_file} --user=#{user}"
    not_if "test -f #{datadir}/mysql/user.frm"
    action :nothing
  end

  # install SSL certificates before config phase
  include_recipe 'percona::ssl' if new_resource.enable_ssl

  if Array(server['role']).include?('cluster')
    wsrep_sst_auth = if node['percona']['cluster']['wsrep_sst_auth'] == ''
                       "#{node['percona']['backup']['username']}:#{passwords.backup_password}"
                     else
                       node['percona']['cluster']['wsrep_sst_auth']
                     end
  end

  # setup the main server config file
  template percona['main_config_file'] do
    if Array(server['role']).include?('cluster')
      source node['percona']['main_config_template']['source']['cluster']
    else
      source node['percona']['main_config_template']['source']['default']
    end
    cookbook node['percona']['main_config_template']['cookbook']
    owner 'root'
    group 'root'
    mode '0644'
    sensitive true
    if Array(server['role']).include?('cluster')
      variables(wsrep_sst_auth: wsrep_sst_auth)
    end
    notifies :run, 'execute[setup mysql datadir]', :immediately
    if node['percona']['auto_restart']
      notifies :restart, 'service[mysql]', :immediately
    end
  end

  # Set the root password only if this is the initial install
  execute 'Update MySQL root password' do # ~FC009 - `sensitive`
    command "mysqladmin --user=root --password='' password '#{passwords.root_password}'"
    only_if "mysqladmin --user=root --password='' version"
    not_if { node['percona']['skip_passwords'] }
    sensitive true
  end

  # Setup the Debian system user config
  template '/etc/mysql/debian.cnf' do
    source 'debian.cnf.erb'
    variables(debian_password: passwords.debian_password)
    owner 'root'
    group 'root'
    mode '0640'
    sensitive true
    if new.auto_restart
      notifies :restart, 'service[mysql]', :immediately
    end
    only_if { platform_family?('debian') }
  end
end
