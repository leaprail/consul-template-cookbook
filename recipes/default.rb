service_group = group node['consul_template']['service_group'] do
  comment "Service group for #{name}"
  system true
  not_if { node['consul_template']['service_user'] == 'root' }
  not_if { node['consul_template']['create_service_user'] == false }
end

service_user = user node['consul_template']['service_user'] do
  comment "Service user for #{name}"
  group service_group.name
  home node['consul_template']['config_dir']
  manage_home false
  shell '/usr/sbin/nologin'
  system true
  not_if { node['consul_template']['service_user'] == 'root' }
  not_if { node['consul_template']['create_service_user'] == false }
  action [:create, :modify]
end

directory node['consul_template']['config_dir'] do
  owner service_user.name
  group service_group.name
end

# ==== Install Consul Template from binary =============================================================================
install_arch = if node['kernel']['machine'].include?('arm64')
                 'arm64'
               elsif node['kernel']['machine'].include?('arm')
                 'arm'
               elsif node['kernel']['machine'].include?('i386')
                 '386'
               else
                 'amd64'
               end
install_version = ['consul-template', node['consul_template']['version'], 'linux', install_arch].join('_')

url = ::URI.join(node['consul_template']['base_url'], "#{node['consul_template']['version']}/", "#{install_version}.tgz").to_s
install_path = "#{node['consul_template']['install_dir']}/#{install_version}"

directory install_path do
  owner service_user.name
  group service_group.name
end

tar_extract url do
  checksum node['consul_template']['checksums'][install_version]
  target_dir install_path
  creates "#{node['consul_template']['install_dir']}/consul-template"
  user service_user.name
  group service_group.name
  mode '0755'
end

link "#{node['consul_template']['install_dir']}/consul-template" do
  to "#{install_path}/consul-template"
  mode '0755'
end

# ==== Create Service ==================================================================================================
consul_addr = node['consul_template']['consul_addr']
consul_addr_option = consul_addr.nil? || consul_addr.empty? ? '' : " -consul-addr #{node['consul_template']['consul_addr']}"

vault_addr = node['consul_template']['vault_addr']
vault_addr_option = vault_addr.nil? || vault_addr.empty? ? '' : " -vault-addr #{node['consul_template']['vault_addr']}"

command = "#{node['consul_template']['install_dir']}/consul-template -config #{node['consul_template']['config_dir']}" \
          "#{consul_addr_option}#{vault_addr_option} -log-level #{node['consul_template']['log_level']}"

systemd_unit 'consul-template.service' do
  content <<-EOF
[Unit]
Description=Consul Template Daemon
Requires=network-online.target
Wants=vault.service consul.service
After=network-online.target vault.service consul.service

[Service]
Environment=#{node['consul_template']['environment_variables'].map { |key, val| %("#{key}=#{val}") }.join(' ')}
ExecStart=#{command}
ExecStop=/bin/kill -INT $MAINPID
ExecReload=/bin/kill -HUP $MAINPID
User=#{service_user.name}
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

  action [:create, :enable]
end

service 'consul-template' do
  supports status: true, restart: true, reload: true
  action :start
end
