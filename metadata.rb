name             'consul-template-cookbook'
issues_url       'https://github.com/ist-dsi/consul-template-cookbook/issues'
source_url       'https://github.com/ist-dsi/consul-template-cookbook'
maintainer       'Simão Martins'
maintainer_email 'simao.martins@tecnico.ulisboa.pt'
license          'Apache-2.0'
description      'Installs/Configures consul-template. This is a fork of the consul-template cookbook which fixes some errors and removes support for Windows.'
long_description 'Installs/Configures consul-template'
version          '0.2.3'
chef_version     '>= 14.10'

recipe 'consul-template-cookbook', 'Installs, configures, and starts the consul-template service.'

supports 'ubuntu', '>= 18.04'
supports 'debian', '>= 9.8'
supports 'centos', '>= 7.6'

%w(tar poise-service).each do |dep|
  depends dep
end
