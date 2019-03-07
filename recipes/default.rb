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

include_recipe "hops_airflow::db"
include_recipe "hops_airflow::packages"

hopsworksUser = "glassfish"
if node.attribute? "hopsworks"
    if node["hopsworks"].attribute? "user"
       hopsworksUser = node['hopsworks']['user']
    end
end

group node['airflow']['group'] do
  action :modify
  members [hopsworksUser]  
  append true
end

include_recipe "hops_airflow::config"
include_recipe "hops_airflow::services"

directory node['airflow']['base_dir'] + "/plugins"  do
  owner node['airflow']['user']
  group node['airflow']['group']
  mode "770"
  action :create
end

directory node['airflow']['base_dir'] + "/dags"  do
  owner node['airflow']['user']
  group node['airflow']['group']
  mode "770"
  action :create
end

template "airflow_services_env" do
  source "init_system/airflow-env.erb"
  path node["airflow"]["env_path"]
  owner node['airflow']['user']
  group "root"
  mode "0644"
  variables({
    :is_upstart => node["airflow"]["is_upstart"],
    :config => node["airflow"]["config"]
  })
end


bash 'mysql_hack_fix' do
  user 'root'
  code <<-EOF
    mkdir -p /var/run/mysqld
    ln -s /tmp/mysql.sock /var/run/mysqld/mysqld.sock
  EOF
  not_if "test -e /var/run/mysqld/mysqld.sock"
end


#
# Run airflow upgradedb - not airflow initdb. See:
# https://medium.com/datareply/airflow-lesser-known-tips-tricks-and-best-practises-cf4d4a90f8f
#
bash 'init_airflow_db' do
  user node['airflow']['user']
  code <<-EOF
      set -e
      export AIRFLOW_HOME=#{node['airflow']['base_dir']}
      #{node['airflow']['bin_path']}/airflow upgradedb
    EOF
end

bash 'create_owners_idx' do
  user "root"
  group "root"
  code <<-EOH
       set -e
       #{node['ndb']['scripts_dir']}/mysql-client.sh -e \"call airflow.create_idx('airflow', 'dag', 'owners', 'owners_idx')\"
       EOH
end

include_recipe "hops_airflow::webserver"
include_recipe "hops_airflow::scheduler"

template node['airflow']['base_dir'] + "/create-default-user.sh" do
  source "create-default-user.sh.erb"
  owner node['airflow']['user']
  group node['airflow']['group']
  mode "0774"
end

examples_dir = "#{node['conda']['base_dir']}/envs/airflow/lib/python3.7/site-packages/airflow/example_dags"
if not node['airflow']['config']['core']['load_examples']
  bash 'remove_examples' do
    user "root"
    code <<-EOF
      rm -rf "#{examples_dir}/*"
    EOF
    only_if "test -d #{examples_dir}", :user => "root"
  end
end  
