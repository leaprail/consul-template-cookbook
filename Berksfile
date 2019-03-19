source 'https://supermarket.chef.io'

metadata

cookbook 'tar', '~> 2.2.0'
cookbook 'poise-service', '~> 1.5.2'

group :integration do
  cookbook 'consul', '~> 3.1.0'
  cookbook 'selinux', '~> 2.1.1'
  cookbook 'test', path: 'test/cookbooks/test'
end
