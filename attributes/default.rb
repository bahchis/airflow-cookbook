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
default[:airflow][:user] = "airflow"
default[:airflow][:group] = "airflow"
default[:airflow][:user_uid] = 9999
default[:airflow][:group_gid] = 9999
default[:airflow][:user_home_directory] = "/home/#{node[:airflow][:user]}"
default[:airflow][:shell] = "/bin/bash"

# General config
default[:airflow][:directories_mode] = "0775"
default[:airflow][:config_file_mode] = "0644"
default[:airflow][:log_path] = "/var/log/airflow"
default[:airflow][:run_path] = "/var/run/airflow"

# airflow.cfg configurations. The required entries listed below, you can add more sections and configs.
# The structure: default[:airflow][:config][CONFIG_SECTION][CONFIG_ENTRY]

# Required core airflow.cfg settings
default[:airflow][:config][:core][:airflow_home] = "/usr/local/lib/airflow"
default[:airflow][:config][:core][:dags_folder] = "#{node[:airflow][:config][:core][:airflow_home]}/dags"
default[:airflow][:config][:core][:plugins_folder] = "#{node[:airflow][:config][:core][:airflow_home]}/plugins"
default[:airflow][:config][:core][:sql_alchemy_conn] = "sqlite:///#{node[:airflow][:config][:core][:airflow_home]}/airflow.db"
default[:airflow][:config][:core][:executor] = "LocalExecutor"
default[:airflow][:config][:core][:parallelism] = 32
default[:airflow][:config][:core][:load_examples] = false
default[:airflow][:config][:core][:fernet_key] = "G3jB5--jCQpRYp7hwUtpfQ_S8zLRbRMwX8tr3dehnNU="

# Required webserver airflow.cfg settings
default[:airflow][:config][:webserver][:web_server_host] = "0.0.0.0"
default[:airflow][:config][:webserver][:web_server_port] = 8080
default[:airflow][:config][:webserver][:base_url] = "http://#{node[:fqdn]}:#{node[:airflow][:config][:webserver][:web_server_port]}"
default[:airflow][:config][:webserver][:secret_key] = "temporary_key"
default[:airflow][:config][:webserver][:expose_config] = true
default[:airflow][:config][:webserver][:authenticate] = false
default[:airflow][:config][:webserver][:filter_by_owner] = false
default[:airflow][:config][:webserver][:load_examples] = false

# Required scheduler airflow.cfg settings
default[:airflow][:config][:scheduler][:job_heartbeat_sec] = 5
default[:airflow][:config][:scheduler][:scheduler_heartbeat_sec] = 5

# Required celery airflow.cfg settings 
default[:airflow][:config][:celery][:celery_app_name] = "airflow.executors.celery_executor"
default[:airflow][:config][:celery][:celeryd_concurrency] = 16
default[:airflow][:config][:celery][:worker_log_server_port] = 8793
default[:airflow][:config][:celery][:broker_url] = "sqla+mysql://airflow:airflow@localhost:3306/airflow"
default[:airflow][:config][:celery][:celery_result_backend] = "db+mysql://airflow:airflow@localhost:3306/airflow"
default[:airflow][:config][:celery][:flower_port] = 5555
default[:airflow][:config][:celery][:default_queue] = "default"