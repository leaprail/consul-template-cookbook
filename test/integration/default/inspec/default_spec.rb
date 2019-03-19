describe file('/usr/local/bin/consul-template') do
  it { should be_file }
  it { should be_executable }
end

describe service('consul-template') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/consul-template.d/test') do
  it { should be_file }

  its(:content) { should match 'source = "/tmp/test.config.ctmpl"' }
  its(:content) { should match 'destination = "/tmp/test.config"' }
  its(:content) { should match 'command = "touch /tmp/consul-template-command-test"' }
end

describe file('/tmp/consul-template-command-test') do
  it { should be_file }
end