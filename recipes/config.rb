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

hopsworks_ip = "localhost"
hopsworks_port = "8181"
if node.attribute?("hopsworks")
  hopsworks_ip = private_recipe_ip("hopsworks", "default")
  if node['hopsworks'].attribute?("secure_port")
    hopsworks_port = node['hopsworks']['secure_port']
  end
end

node.override['airflow']["config"]["webserver"]["hopsworks_host"] = hopsworks_ip
node.override['airflow']["config"]["webserver"]["hopsworks_port"] = hopsworks_port

template "#{node["airflow"]["config"]["core"]["airflow_home"]}/airflow.cfg" do
  source "airflow.cfg.erb"
  owner node["airflow"]["user"]
  group node["airflow"]["group"]
  mode node["airflow"]["config_file_mode"]
  variables(
    lazy do
      {
        :config => node['airflow']['config']
      }
    end
  )
end
