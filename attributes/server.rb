case node["platform_family"]
when "debian"
  normal['percona']['server']['packages'] = %w{percona-server-server-5.5}
when "rhel"
  normal['percona']['server']['packages'] = %w{Percona-Server-server-55}
end
