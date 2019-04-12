poise_service_user node['consul_template']['service_user'] do
  group node['consul_template']['service_group']
  home '/dev/null'
  shell '/bin/false'
  not_if { node['consul_template']['service_user'] == 'root' }
  not_if { node['consul_template']['create_service_user'] == false }
end

group node['consul_template']['service_group'] do
  system true
  not_if { node['consul_template']['service_group'] == 'root' }
  # When user is root the poise_server_user wont create the group
  only_if { node['consul_template']['service_user'] == 'root' }
end

directory node['consul_template']['config_dir'] do
  owner node['consul_template']['service_user']
  group node['consul_template']['service_group']
  mode 0o755
end

file File.join(node['consul_template']['config_dir'], 'default.json') do
  user node['consul_template']['service_user']
  group node['consul_template']['service_group']
  mode node['consul_template']['template_mode']
  sensitive true
  action :create
  content JSON.pretty_generate(node['consul_template']['config'], quirks_mode: true)
  notifies :restart, 'service[consul-template]', :delayed
end

# ==== Install Consul Template from binary =============================================================================

install_arch = if node['kernel']['machine'].include?('arm')
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
  owner node['consul_template']['service_user']
  group node['consul_template']['service_group']
  action :create
end

tar_extract url do
  checksum node['consul_template']['checksums'][install_version]
  target_dir install_path
  creates "#{node['consul_template']['install_dir']}/consul-template"
  user node['consul_template']['service_user']
  group node['consul_template']['service_group']
  mode '0755'
end

link "#{node['consul_template']['install_dir']}/consul-template" do
  to "#{install_path}/consul-template"
  mode '0755'
end

# ==== Create Service ==================================================================================================

command = "#{node['consul_template']['install_dir']}/consul-template"
options = "-config #{node['consul_template']['config_dir']} " \
          "-consul-addr #{node['consul_template']['consul_addr']} " \
          "-vault-addr #{node['consul_template']['vault_addr']}"

poise_service 'consul-template' do
  user node['consul_template']['service_user']
  environment node['consul_template']['environment_variables']
  command "#{command} #{options}"
  stop_signal 'INT'
  reload_signal 'HUP'
  # KillMode=process
  # Restart=on-failure
  # RestartSec=42s
  #
  # [Unit]
  # Description=Consul Template Daemon
  # Wants=basic.target
  # After=basic.target network.target
end

service 'consul-template' do
  supports status: true, restart: true, reload: true
  action %i(enable start)
end
