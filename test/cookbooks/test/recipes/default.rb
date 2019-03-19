include_recipe 'consul-template-cookbook::default'

template '/tmp/test.config.ctmpl' do
  source 'test.config.ctmpl.erb'
end

consul_template_config 'test' do
  templates [{
    source: '/tmp/test.config.ctmpl',
    destination: '/tmp/test.config',
    command: 'touch /tmp/consul-template-command-test',
    perms: 777,
  }]
  notifies :restart, 'service[consul-template]'
end

execute 'add test key/value' do
  command "curl -X PUT -d 'something' http://localhost:8500/v1/kv/test"
end
