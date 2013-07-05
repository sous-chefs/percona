normal['mysql']['use_upstart'] = false

case node["platform_family"]
when "debian"
  normal['mysql']['server']['packages'] = %w{percona-server-server}
when "rhel"
  normal['mysql']['server']['packages'] = %w{Percona-Server-server-55}
  normal['mysql']['service_name'] = "mysql"
  normal['mysql']['pid_file'] = ""
end
