# Copyright 2015 Sergey Bahchissaraitsev

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http//www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# User configuration
default["airflow"]["version"] = nil
default["airflow"]["user"] = "airflow"
default["airflow"]["group"] = "airflow"
default["airflow"]["user_uid"] = 9999
default["airflow"]["group_gid"] = 9999
default["airflow"]["user_home_directory"] = "/home/#{node["airflow"]["user"]}"
default["airflow"]["shell"] = "/bin/bash"

# General config
default["airflow"]["directories_mode"] = "0775"
default["airflow"]["config_file_mode"] = "0644"
default["airflow"]["bin_path"] = node[:platform] == "ubuntu" ? "/usr/local/bin" : "/usr/bin"
default["airflow"]["run_path"] = "/var/run/airflow"
default["airflow"]["init_system"] = node[:platform] == "ubuntu" ? "upstart" : "systemd"

# Configurations stated below are required for this cookbook and wiill be written to airflow.cfg, you can add more config by using structure like:
# default["airflow"]["config"]["CONFIG_SECTION"]["CONFIG_ENTRY"]
default["airflow"]["config"]["core"]["airflow_home"] = node[:platform] == "ubuntu" ? "/usr/local/lib/airflow" : "/usr/lib/airflow"
default["airflow"]["config"]["core"]["dags_folder"] = "#{node["airflow"]["config"]["core"]["airflow_home"]}/dags"
default["airflow"]["config"]["core"]["plugins_folder"] = "#{node["airflow"]["config"]["core"]["airflow_home"]}/plugins"