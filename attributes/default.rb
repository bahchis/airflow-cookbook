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

include_attribute "kagent"
include_attribute "ndb"


# User configuration
default["airflow"]["version"] = nil
default["airflow"]["user"] = "airflow"
default["airflow"]["group"] = "airflow"
default["airflow"]["user_uid"] = 9999
default["airflow"]["group_gid"] = 9999
default["airflow"]["user_home_directory"] = "/home/#{node["airflow"]["user"]}"
default["airflow"]["shell"] = "/bin/bash"

default["airflow"]["dir"]                 = node.install.dir.empty? ? "/srv" : node.install.dir
default["airflow"]["home"]                = node.airflow.dir + "/airflow-" + node.airflow.version
default["airflow"]["base_dir"]            = node.airflow.dir + "/airflow" 


# General config
default["airflow"]["directories_mode"] = "0775"
default["airflow"]["config_file_mode"] = "0644"
default["airflow"]["bin_path"] = node["airflow"]["base_dir"] + "/bin"
default["airflow"]["run_path"] = node["airflow"]["base_dir"] + "/run"
default["airflow"]["is_upstart"] = node["platform"] == "ubuntu" && node["platform_version"].to_f < 15.04
default["airflow"]["init_system"] = node["airflow"]["is_upstart"] ? "upstart" : "systemd"
default["airflow"]["env_path"] = node["airflow"]["base_dir"] + "/etc"


# Python config
default["airflow"]["python_runtime"] = "2"
default["airflow"]["python_version"] = "2.7"
default["airflow"]["pip_version"] = true

# Configurations stated below are required for this cookbook and will be written to airflow.cfg, you can add more config by using structure like:
# default["airflow"]["config"]["CONFIG_SECTION"]["CONFIG_ENTRY"]


default["airflow"]["config"]["core"]["airflow_home"] = node["airflow"]["base_dir"]
default["airflow"]["config"]["core"]["dags_folder"] = "#{node["airflow"]["config"]["core"]["airflow_home"]}/dags"
default["airflow"]["config"]["core"]["plugins_folder"] = "#{node["airflow"]["config"]["core"]["airflow_home"]}/plugins"
#default["airflow"]["config"]["core"]["fernet_key"] = "G3jB5--jCQpRYp7hwUtpfQ_S8zLRbRMwX8tr3dehnNU=" # Be sure to change this for production
# Celery
default["airflow"]["config"]["celery"]["celeryd_concurrency"] = 16
default["airflow"]["config"]["celery"]["broker_url"] = "rdis://#{node['host']}:6379/0"

# MySQL
default["airflow"]["config"]["core"]["sql_alchemy_conn"] = "mysql://#{node['mysql']['user']}:#{node['mysql']['password']}@localhost:3306/airflow"
default["airflow"]["config"]["core"]["sql_alchemy_pool_size"] = 5
default["airflow"]["config"]["core"]["sql_alchemy_pool_recycle"] = 3600

# the max number of task instances that should run simultaneously on this airflow installation
default["airflow"]["config"]["core"]["parallelism"] = 32
# The number of task instances allowed to run concurrently by the scheduler
default["airflow"]["config"]["core"]["dag_concurrency"] = 16
default["airflow"]["config"]["core"]["dags_are_paused_at_creation"] = True
default["airflow"]["config"]["core"]["non_pooled_task_slot_count"] = 128
default["airflow"]["config"]["core"]["max_active_runs_per_dag"] = 16
# How long before timing out a python file import while filling the DagBag
default["airflow"]["config"]["core"]["dagbag_import_timeout"] = 60
default["airflow"]["config"]["core"]["security"] = 'hops'

#default["airflow"]["config"]["core"][""] =

default["airflow"]["config"]["admin"]["hide_sensitive_variable_fields"] = True
default["airflow"]["config"]["github_enterprise"]["api_rev"] = 'v3'


default["airflow"]["config"]["webserver"]["expose_config"] = True
default["airflow"]["config"]["webserver"]["filter_by_owner"] = True
default["airflow"]["config"]["webserver"]["authenticate"] = True
default["airflow"]["config"]["webserver"]["auth_backend"] = hops.airflow.auth.backends.hopsworks
default["airflow"]["config"]["webserver"]["web_server_port"] = 8080
default["airflow"]["config"]["webserver"]["base_url"] = "http://#{node['fqdn']}:#{['airflow']['config']['webserver']['web_server_port']}"
default["airflow"]["config"]["webserver"]["web_server_host"] = 0.0.0.0
#default["airflow"]["config"]["webserver"][""] =

