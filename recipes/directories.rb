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

directory node["airflow"]["dir"]  do
  owner node["airflow"]["user"]
  group node["airflow"]["group"]
  mode "755"
  recursive true
  action :create
  not_if { File.directory?("#{node["airflow"]["dir"]}") }
end

directory node["airflow"]["config"]["core"]["airflow_home"] do
  owner node["airflow"]["user"]
  group node["airflow"]["group"]
  mode node["airflow"]["directories_mode"]
  action :create
end

# /srv/hops/airflow/dags is a private directory - each project will have its own
# directory owned by 'glassfish' with a secret key as a name. No read permissions for
# group on this directory, means the 'glassfish' user cannot perform 'ls' on this directory
# to find out other project's secret keys
directory node["airflow"]["config"]["core"]["dags_folder"] do
  owner node["airflow"]["user"]
  group node["airflow"]["group"]
  mode "710"
  action :create
end

directory node['airflow']['config']['core']['plugins_folder'] do
  owner node['airflow']['user']
  group node['airflow']['group']
  mode node['airflow']['directories_mode']
  action :create
end

directory node['airflow']['run_path'] do
  owner node['airflow']['user']
  group node['airflow']['group']
  mode node['airflow']['directories_mode']
  action :create
end

# Directory where Hopsworks will store JWT for projects
# Directory structure will be secrets/SECRET_PROJECT_ID/project_user.jwt
# secrets dir is not readable so someone must only guess the SECRET_PROJECT_ID
directory "#{node['airflow']['base_dir']}/secrets" do
  owner node['airflow']['user']
  group node['airflow']['group']
  mode 0130
  action :create
end
