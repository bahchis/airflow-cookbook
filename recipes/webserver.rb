# Copyright 2015 Sergey Bahchissaraitsev

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if (node["airflow"]["init_system"] == "upstart") 
  service_target = "/etc/init/airflow-webserver.conf"
  service_template = "init_system/upstart/airflow-webserver.conf.erb"
elsif (node["airflow"]["init_system"] == "systemd" && node["platform"] == "ubuntu" )
  service_target = "/lib/systemd/system/airflow-webserver.service"
  service_template = "init_system/systemd/airflow-webserver.service.erb"
else
  service_target = "/usr/lib/systemd/system/airflow-webserver.service"
  service_template = "init_system/systemd/airflow-webserver.service.erb"
end

template service_target do
  source service_template
  owner "root"
  group "root"
  mode "0644"
  variables({
    :user => node["airflow"]["user"], 
    :group => node["airflow"]["group"],
    :run_path => node["airflow"]["run_path"],
    :bin_path => node["airflow"]["bin_path"],
    :env_path => node["airflow"]["env_path"],
    :base_path => node["airflow"]["base_dir"],
  })
end

# Copy Hopsworks JWT authentication module. PYTHONPATH is exported
# in airflow.env
remote_directory "#{node['airflow']['base_dir']}/hopsworks_auth" do
  source "hopsworks_auth"
  owner node['airflow']['user']
  group node['airflow']['group']
  mode 0740
  files_owner node['airflow']['user']
  files_group node['airflow']['group']
  files_mode 0740
end

remote_directory "#{node['airflow']['config']['core']['plugins_folder']}/hopsworks_plugin" do
  source "hopsworks_plugin"
  owner node['airflow']['user']
  group node['airflow']['group']
  mode 0740
  files_owner node['airflow']['user']
  files_group node['airflow']['group']
  files_mode 0740
end

service "airflow-webserver" do
  action [:enable, :start]
end

if node['kagent']['enabled'] == "true"
    kagent_config "airflow-webserver" do
      service "airflow"
      log_file "#{node["airflow"]["config"]["core"]["base_log_folder"]}/airflow-scheduler.log"
      config_file "#{node['airflow']['base_dir']}/airflow.cfg"
      restart_agent false
      action :add
    end
end

