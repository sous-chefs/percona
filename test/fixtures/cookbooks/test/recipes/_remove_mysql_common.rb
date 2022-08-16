# mailutils pulls in mysql-common which breaks initial installation on dokken based images. This doesn't seem to happen
# in a non-container system so let's have this here for now
if platform_family?('debian')
  execute 'remove mysql-common' do
    command <<~EOF
      apt-get -y remove mailutils mailutils-common
      apt-get -y autoremove
    EOF
    only_if { ::File.exist?('/usr/share/doc/mailutils-common/copyright') }
  end
end
