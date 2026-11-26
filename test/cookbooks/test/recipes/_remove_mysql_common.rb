# frozen_string_literal: true

# mailutils pulls in mysql-common which breaks initial installation on dokken based images.
execute 'remove mysql-common' do
  command <<~SH
    apt-get -y remove mailutils mailutils-common
    apt-get -y autoremove
  SH
  only_if { platform_family?('debian') && ::File.exist?('/usr/share/doc/mailutils-common/copyright') }
end
