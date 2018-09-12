# coding: utf-8

# coding: utf-8
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




# CREATE DATABASE airflow CHARACTER SET utf8 COLLATE utf8_unicode_ci;
# grant all on airflow.* TO ‘USERNAME'@'%' IDENTIFIED BY ‘{password}';

exec = "#{node['ndb']['scripts_dir']}/mysql-client.sh"

bash 'create_airflow_db' do
  user "root"
  code <<-EOF
      set -e
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS airflow CHARACTER SET latin1\"
      #{exec} -e \"GRANT ALL PRIVILEGES ON airflow.* TO '#{node[:mysql][:user]}'@'localhost' IDENTIFIED BY '#{node[:mysql][:password]}'\"
    EOF
  not_if "#{exec} -e 'show databases' | grep airflow"
end

include_recipe "hops_airflow::config"
include_recipe "hops_airflow::services"


directory node['airflow']['base_dir'] + "/plugins"  do
  owner node['airflow']['user']
  group node['airflow']['group']
  mode "770"
  action :create
end


template node['airflow']['base_dir'] + "/plugins/hopsworks_job_operator.py" do
  source "hopsworks_job_operator.py.erb"
  owner node['airflow']['user']
  group node['airflow']['group']
  mode "0644"
  variables({
    :config => node["airflow"]["config"]
  })
end


template "airflow_services_env" do
  source "init_system/airflow-env.erb"
  path node["airflow"]["env_path"]
  owner "root"
  group "root"
  mode "0644"
  variables({
    :is_upstart => node["airflow"]["is_upstart"],
    :config => node["airflow"]["config"]
  })
end


bash 'init_airflow_db' do
  user node['airflow']['user']
  code <<-EOF
      set -e
      export AIRFLOW_HOME=#{node['airflow']['base_dir']}
      airflow initdb
    EOF
end


include_recipe "hops_airflow::webserver"
include_recipe "hops_airflow::scheduler"
include_recipe "hops_airflow::worker"
