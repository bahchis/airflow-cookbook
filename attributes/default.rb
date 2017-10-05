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

# User configuration
default["airflow"]["airflow_package"] = 'apache-airflow' # use 'airflow' for version <= 1.8.0
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
default["airflow"]["bin_path"] = node["platform"] == "ubuntu" ? "/usr/local/bin" : "/usr/bin"
default["airflow"]["run_path"] = "/var/run/airflow"
default["airflow"]["is_upstart"] = node["platform"] == "ubuntu" && node["platform_version"].to_f < 15.04
default["airflow"]["init_system"] = node["airflow"]["is_upstart"] ? "upstart" : "systemd"
default["airflow"]["env_path"] = node["platform_family"] == "debian" ? "/etc/default/airflow" : "/etc/sysconfig/airflow"


# Python config
default["airflow"]["python_runtime"] = "2"
default["airflow"]["python_version"] = "2.7"
default["airflow"]["pip_version"] = true

# Configurations stated below are required for this cookbook and will be written to airflow.cfg, you can add more config by using structure like:
# default["airflow"]["config"]["CONFIG_SECTION"]["CONFIG_ENTRY"]

# Core
default["airflow"]["config"]["core"]["airflow_home"] = node["platform"] == "ubuntu" ? "/usr/local/lib/airflow" : "/usr/lib/airflow"
default["airflow"]["config"]["core"]["dags_folder"] = "#{node["airflow"]["config"]["core"]["airflow_home"]}/dags"
default["airflow"]["config"]["core"]["plugins_folder"] = "#{node["airflow"]["config"]["core"]["airflow_home"]}/plugins"
default["airflow"]["config"]["core"]["sql_alchemy_conn"] = "sqlite:///#{node["airflow"]["config"]["core"]["airflow_home"]}/airflow.db"
default["airflow"]["config"]["core"]["fernet_key"] = "G3jB5--jCQpRYp7hwUtpfQ_S8zLRbRMwX8tr3dehnNU=" # Be sure to change this for production
# Celery
default["airflow"]["config"]["celery"]["celeryd_concurrency"] = 16
