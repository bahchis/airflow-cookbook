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

include_recipe 'apt'
include_recipe 'airflow::user'
include_recipe 'airflow::directories'

airflow 'airflow_install' do 
	action :install
end

template "#{node["airflow"]["config"]["core"]["airflow_home"]}/airflow.cfg" do
  source 'airflow.cfg.erb'
  owner node["airflow"]["user"]
  group node["airflow"]["group"]
  mode node["airflow"]["config_file_mode"]
  variables({
  	:config => node["airflow"]["config"] 
  })
end

bash 'airflow_home_env' do
  code <<-EOH
      echo "\n# Airflow Home\nexport AIRFLOW_HOME=#{node["airflow"]["config"]["core"]["airflow_home"]}" >> /etc/bash.bashrc
    EOH
end

bash 'airflow_initdb' do
  user node["airflow"]["user"]
  group node["airflow"]["group"]
  environment({
    'AIRFLOW_HOME' => node["airflow"]["config"]["core"]["airflow_home"]
  })
  code <<-EOH
      /usr/local/bin/airflow initdb
    EOH
end