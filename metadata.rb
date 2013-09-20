name             'zwift'
maintainer       'ZeroVM'
license          'Apache 2.0'
description      'Installs/Configures zwift'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'ubuntu'

%w{ swift-lite osops-utils runit git mysql-openstack keystone cron }.each do |dep|
  depends dep
end

