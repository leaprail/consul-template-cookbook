name             'consul-template-cookbook'
maintainer       'Simão Martins'
maintainer_email 'simao.martins@tecnico.ulisboa.pt'
license          'Apache-2.0'
description      'Installs/Configures consul-template. This is a fork of the consul-template cookbook which fixes some errors and removes support for Windows.'
long_description 'Installs/Configures consul-template'
version          '0.1.0'

recipe 'consul-template-cookbook', 'Installs, configures, and starts the consul-template service.'

supports 'ubuntu', '>= 18.04'
supports 'debian', '>= 9.8'
supports 'centos', '>= 7.6'

%w(tar poise-service).each do |dep|
  depends dep
end

issues_url 'https://github.com/adamkrone/chef-consul-template/issues'
source_url 'https://github.com/adamkrone/chef-consul-template'
chef_version '>= 14.10'
