# verify ruby dependency
verify_ruby 'Beanstalkd Plugin'

# check required attributes
verify_attributes do
  attributes [
    'node[:newrelic][:license_key]', 
    'node[:newrelic][:beanstalkd][:install_path]', 
    'node[:newrelic][:beanstalkd][:user]', 
    'node[:newrelic][:beanstalkd][:servername]',
    'node[:newrelic][:beanstalkd][:hostname]',
    'node[:newrelic][:beanstalkd][:port]'
  ]
end

verify_license_key node[:newrelic][:license_key]

install_plugin 'newrelic_beanstalkd_plugin' do
  plugin_version   node[:newrelic][:beanstalkd][:version]
  install_path     node[:newrelic][:beanstalkd][:install_path]
  plugin_path      node[:newrelic][:beanstalkd][:plugin_path]
  download_url     node[:newrelic][:beanstalkd][:download_url]
  user             node[:newrelic][:beanstalkd][:user]
end

# newrelic template
template "#{node[:newrelic][:beanstalkd][:plugin_path]}/config/newrelic_plugin.yml" do
  source 'beanstalkd/newrelic_plugin.yml.erb'
  action :create
  owner node[:newrelic][:beanstalkd][:user]
  notifies :restart, 'service[newrelic-beanstalkd-plugin]'
end

# install bundler gem and run 'bundle install'
bundle_install do
  path node[:newrelic][:beanstalkd][:plugin_path]
  user node[:newrelic][:beanstalkd][:user]
end

# make sure newrelic_beanstalkd is executable
execute 'newrelic-beanstalkd-plugin-chmod' do
  user 'root'
  cwd node[:newrelic][:beanstalkd][:plugin_path]
  command 'chmod +x bin/newrelic_beanstalkd'
  action :run
end

# install init.d script and start service
plugin_service 'newrelic-beanstalkd-plugin' do
  daemon          './bin/newrelic_beanstalkd'
  daemon_dir      node[:newrelic][:beanstalkd][:plugin_path]
  plugin_name     'Beanstalkd'
  plugin_version  node[:newrelic][:beanstalkd][:version]
  run_command     "sudo -u #{node[:newrelic][:beanstalkd][:user]} bundle exec"
end