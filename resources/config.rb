resource_name :consul_template_config
provides :consul_template_config

default_action :create

property :templates, Array, default: []
# Each element of the array should a Hash with the following values:
# property :source, String, required: true
# property :destination, String, required: true
# property :contents, String
# property :command, String
# property :command_timeout, String, default: '30s'
# property :perms, String, default: 0600
# property :backup, Boolean, default: true
# property :left_delimiter, String, default: '{{'
# property :right_delimiter, String, default: '}}'
# property :wait, String, default: '2s:10s'

action :create do
  templates = new_resource.templates.map { |v| Mash.from_hash(v) }

  # Create entries in configs-template dir but only if it's well formed
  templates.each_with_index do |v, i|
    raise "Missing source and contents for #{i} entry at '#{new_resource.name}" if v[:source].nil? && v[:contents].nil?
    raise "Missing destination for #{i} entry at '#{new_resource.name}" if v[:destination].nil?
  end

  # Ensure config directory exists
  directory node['consul_template']['config_dir'] do
    user node['consul_template']['service_user']
    group node['consul_template']['service_group']
    mode '0755'
    recursive true
    action :create
  end

  template ::File.join(node['consul_template']['config_dir'], new_resource.name) do
    cookbook 'consul-template-cookbook'
    source 'config-template.json.erb'
    sensitive true
    user node['consul_template']['service_user']
    group node['consul_template']['service_group']
    mode node['consul_template']['template_mode']
    variables(templates: templates)
    not_if { templates.empty? }
  end
end

action :delete do
  file ::File.join(node['consul_template']['config_dir'], new_resource.name) do
    action :delete
  end
end
