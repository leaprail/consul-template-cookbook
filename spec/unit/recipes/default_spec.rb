require 'spec_helper'

describe 'consul-template::default' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'centos', version: '7.6').converge('consul-template-cookbook::default')
  end
  let(:consul_template_tgz) { "consul-template_#{chef_run.node['consul_template']['version']}_linux_amd64" }

  # Installation
  it 'symlinks to /usr/local/bin/consul-template' do
    expect(chef_run).to create_link('/usr/local/bin/consul-template')
  end

  # Service
  it 'should create the consul-template config directory' do
    expect(chef_run).to create_directory('/etc/consul-template.d')
  end

  it 'should create the consul-template default config' do
    expect(chef_run).to create_file('/etc/consul-template.d/default.json')
  end

  it 'should enable the consul-template service' do
    expect(chef_run).to enable_service('consul-template')
  end

  it 'should start the consul-template service' do
    expect(chef_run).to start_service('consul-template')
  end

  it 'should create the consul-template service user' do
    expect(chef_run).to create_poise_service_user('consul-template')
  end

  it 'should enable the consul-template service' do
    expect(chef_run).to enable_service('consul-template')
  end

  it 'should start the consul-template service' do
    expect(chef_run).to start_service('consul-template')
  end
end
