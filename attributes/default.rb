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
default["airflow"]["airflow_package"] = 'apache-airflow' # use 'airflow' for version <= 1.8.0
default["airflow"]["version"] = "1.10.0"
default["airflow"]["user"] = "airflow"
default["airflow"]["group"] = "airflow"
default["airflow"]["user_uid"] = 9999
default["airflow"]["group_gid"] = 9999
default["airflow"]["user_home_directory"] = "/home/#{node['airflow']['user']}"
default["airflow"]["shell"] = "/bin/bash"

default["airflow"]["dir"]                 = node['install']['dir'].empty? ? "/srv" : node['install']['dir']
default["airflow"]["home"]                = node['airflow']['dir'] + "/airflow-" +  node['airflow']['version']
default["airflow"]["base_dir"]            = node['airflow']['dir'] + "/airflow" 


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

#  The home folder for airflow, default is ~/airflow
#  airflow_home = /Users/p1nox/airflow
default["airflow"]["config"]["core"]["airflow_home"] = node["airflow"]["base_dir"]
# The folder where your airflow pipelines live, most likely a subfolder in a code repository
default["airflow"]["config"]["core"]["dags_folder"] = "#{node["airflow"]["config"]["core"]["airflow_home"]}/dags"
# The folder where airflow should store its log files. This location
default["airflow"]["config"]["core"]["base_log_folder"]  = node["airflow"]["base_dir"] + "/logs"

# must supply a remote location URL (starting with either 's3://...' or
# 'gs://...') and an Airflow connection id that provides access to the storage
# location.
# remote_base_log_folder =
# remote_log_conn_id =
# Use server-side encryption for logs stored in S3
# encrypt_s3_logs = false


# Whether to disable pickling dags
default["airflow"]["config"]["core"]["donot_pickle"]  = false
 
# Where your Airflow plugins are stored
default["airflow"]["config"]["core"]["plugins_folder"] = "#{node["airflow"]["config"]["core"]["airflow_home"]}/plugins"

#default["airflow"]["config"]["core"]["fernet_key"] = cryptography_not_found_storing_passwords_in_plain_text
default["airflow"]["config"]["core"]["fernet_key"] = "G3jB5--jCQpRYp7hwUtpfQ_S8zLRbRMwX8tr3dehnNU=" # Be sure to change this for production

# Celery
default["airflow"]["config"]["celery"]["celeryd_concurrency"] = 16
default["airflow"]["config"]["celery"]["broker_url"] = "rdis://#{node['host']}:6379/0"
default["airflow"]["config"]["celery"]["celery_result_backend"] = "db+mysql://#{node['mysql']['user']}:#{node['mysql']['password']}@localhost:3306/airflow"

# MySQL
# The SqlAlchemy connection string to the metadata database.
default["airflow"]["config"]["core"]["sql_alchemy_conn"] = "mysql://#{node['mysql']['user']}:#{node['mysql']['password']}@localhost:3306/airflow"
# The SqlAlchemy pool size is the maximum number of database connection in the pool.
default["airflow"]["config"]["core"]["sql_alchemy_pool_size"] = 5
# The SqlAlchemy pool recycle is the number of seconds a connection
# can be idle in the pool before it is invalidated. 
default["airflow"]["config"]["core"]["sql_alchemy_pool_recycle"] = 3600

# The amount of parallelism as a setting to the executor. This defines
# the max number of task instances that should run simultaneously
# on this airflow installation
default["airflow"]["config"]["core"]["parallelism"] = 32
# The number of task instances allowed to run concurrently by the scheduler
default["airflow"]["config"]["core"]["dag_concurrency"] = 16
default["airflow"]["config"]["core"]["dags_are_paused_at_creation"] = true
# When not using pools, tasks are run in the "default pool", whose size is guided by this config element
default["airflow"]["config"]["core"]["non_pooled_task_slot_count"] = 128
default["airflow"]["config"]["core"]["max_active_runs_per_dag"] = 16
# How long before timing out a python file import while filling the DagBag
default["airflow"]["config"]["core"]["dagbag_import_timeout"] = 60

#default["airflow"]["config"]["core"]["security"] = 'hops'


# The default owner assigned to each new operator, unless
# provided explicitly or passed via `default_args`
default["airflow"]["config"]["operators"]["default_owner"]  = "Airflow"


default["airflow"]["config"]["admin"]["hide_sensitive_variable_fields"] = true
default["airflow"]["config"]["github_enterprise"]["api_rev"] = 'v3'

# The executor class that airflow should use. Choices include
# SequentialExecutor, LocalExecutor, CeleryExecutor
default["airflow"]["config"]["core"]["executor"]  = "LocalExecutor"

# Celery
default["airflow"]["config"]["celery"]["celeryd_concurrency"] = 16
default["airflow"]["config"]["celery"]["broker_url"] = "rdis://#{node['host']}:6379/0"


# The base url of your website as airflow cannot guess what domain or
# cname you are using. This is used in automated emails that
# airflow sends to point links to the right web server
default["airflow"]["config"]["webserver"]["web_server_worker_timeout"]  = 120
default["airflow"]["config"]["webserver"]["web_server_port"] = 12358
default["airflow"]["config"]["webserver"]["base_url"] = "http://#{node['fqdn']}:" + node['airflow']['config']['webserver']['web_server_port'].to_s
default["airflow"]["config"]["webserver"]["web_server_host"] = '0.0.0.0'
# The port on which to run the web server
# The time the gunicorn webserver waits before timing out on a worker

default["airflow"]["config"]["webserver"]["expose_config"] = true
default["airflow"]["config"]["webserver"]["filter_by_owner"] = true
default["airflow"]["config"]["webserver"]["authenticate"] = true

default["airflow"]["config"]["webserver"]["auth_backend"] = "airflow.contrib.auth.backends.password_auth"
#default["airflow"]["config"]["webserver"]["auth_backend"] = hops.airflow.auth.backends.hopsworks

# Secret key used to run your flask app
default["airflow"]["config"]["webserver"]["secret_key"]  = "temporary_key"
# Number of workers to run the Gunicorn web server
default["airflow"]["config"]["webserver"]["workers"]  = 4
# The worker class gunicorn should use. Choices include
# sync (default), eventlet, gevent
default["airflow"]["config"]["webserver"]["worker_class"]  = "sync"

default["airflow"]["config"]["webserver"]["expose_config"]  = true

# Email
default["airflow"]["config"]["email"]["email_backend"]  = "airflow.utils.email.send_email_smtp"

# SMTP
# If you want airflow to send emails on retries, failure, and you want to use
# the airflow.utils.email.send_email_smtp function, you have to configure an smtp
# server here
#
default["airflow"]["config"]["smtp"]["smtp_host"]  = "localhost"
default["airflow"]["config"]["smtp"]["smtp_starttls"]  = true
default["airflow"]["config"]["smtp"]["smtp_ssl"]  = false
default["airflow"]["config"]["smtp"]["smtp_user"]  = "admin@kth.se"
default["airflow"]["config"]["smtp"]["smtp_port"]  = 25
default["airflow"]["config"]["smtp"]["smtp_password"]  = "admin"
default["airflow"]["config"]["smtp"]["smtp_mail_from"]  = "admin@kth.se"

#
# This section only applies if you are using the CeleryExecutor in [core] section above
#
# The app name that will be used by celery
default["airflow"]["config"]["celery"]["celery_app_name"]  = "airflow.executors.celery_executor"
# The concurrency that will be used when starting workers with the
# "airflow worker" command. This defines the number of task instances that
# a worker will take, so size up your workers based on the resources on
# your worker box and the nature of your tasks
default["airflow"]["config"]["celery"]["celeryd_concurrency"]  = 16
# When you start an airflow worker, airflow starts a tiny web server
# subprocess to serve the workers local log files to the airflow main
# web server, who then builds pages and sends them to users. This defines
# the port on which the logs are served. It needs to be unused, and open
# visible from the main web server to connect into the workers.
default["airflow"]["config"]["celery"]["worker_log_server_port"]  = 8793
# The Celery broker URL. Celery supports RabbitMQ, Redis and experimentally
# a sqlalchemy database. Refer to the Celery documentation for more
# information.
default["airflow"]["config"]["celery"]["broker_url"]  = "amqp://guest:guest@127.0.0.1/"
# Another key Celery setting
default["airflow"]["config"]["celery"]["celery_result_backend"]  = "db+mysql://airflow:airflow@localhost:3306/airflow"
# Celery Flower is a sweet UI for Celery. Airflow has a shortcut to start
# it `airflow flower`. This defines the port that Celery Flower runs on
default["airflow"]["config"]["celery"]["flower_port"]  = 5555
# Default queue that tasks get assigned to and that worker listen on.
default["airflow"]["config"]["celery"]["default_queue"]  = "default"

#
# Scheduler
#
# Task instances listen for external kill signal (when you clear tasks
# from the CLI or the UI), this defines the frequency at which they should
# listen (in seconds).
default["airflow"]["config"]["scheduler"]["job_heartbeat_sec"]  = 5
# The scheduler can run multiple threads in parallel to schedule dags.
# This defines how many threads will run. However airflow will never
# use more threads than the amount of cpu cores available.
default["airflow"]["config"]["scheduler"]["max_threads"]  = 2

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http//www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Core packages - built to match the Setup.py file in the Aiflow repository.
# default['airflow']['packages'] =
#   {
#     async: [{ name: 'greenlet', version: '>=0.4.9' },
#             { name: 'eventlet', version: '>=0.9.7' },
#             { name: 'gevent', version: '>=0.13' }],
#     azure: [{ name: 'azure_blob_storage', version: '>=0.34.0'}],
#     celery: [{ name: 'celery', version: '>=4.1.0, <4.2.0' }],
#     cgroups: [{ name: 'cgroupspy', version: '>=0.1.4' }],
#     crypto: [{ name: 'cryptography', version: '>=0.9.3' }],
#     dask: [{ name: 'distributed', version: '1.15.2, <2' }],
#     databricks: [{name: 'requests', version: '>=2.5.1, <3'}],
#     datadog: [{ name: 'datadog', version: '>=0.14.0' }],
#     doc: [{ name: 'sphinx', version: '>=1.2.3' },
#           { name: 'sphinx-argparse', version: '>=0.1.13' },
#           { name: 'sphinx-rtd-theme', version: '>=0.1.6' },
#           { name: 'Sphinx-PyPI-upload', version: '>=0.2.1' }],
#     docker: [{ name: 'docker-py', version: '>=1.6.0' }],
#     druid: [{ name: 'druid', version: '>=0.4.1' }],
#     emr: [{ name: 'boto3', version: '>=1.0.0' }],
#     gcp_api: [{ name: 'httplib2', version: '' },
#               { name: 'google-api-python-client', version: '>=1.5.0, <1.6.0' },
#               { name: 'oauth2client', version: '>=2.0.2, <2.1.0' },
#               { name: 'pandas-gbq', version: '' },
#               { name: 'google-cloud-dataflow', version: '' },
#               { name: 'PyOpenSSL', version: '' }],
#     hdfs: [{ name: 'snakebite', version: '>=2.7.8' }],
#     webhdfs: [{ name: 'hdfs[dataframe,avro,kerberos]', version: '>=2.0.4' }],
#     hive: [{ name: 'hive-thrift-py', version: '>=0.0.1' },
#            { name: 'pyhive', version: '>=0.1.3' },
#            { name: 'impyla', version: '>=0.13.3' },
#            { name: 'unicodecsv', version: '>=0.14.1' }],
#     jira: [{ name: 'JIRA', version: '>1.0.7'}],
#     jdbc: [{ name: 'jaydebeapi', version: '>=1.1.1' }],
#     mssql: [{ name: 'pymssql', version: '>=2.1.1' },
#             { name: 'unicodecsv', version: '>=0.14.1' }],
#     mysql: [{ name: 'mysqlclient', version: '>=1.3.6' }],
#     rabbitmq: [{ name: 'librabbitmq', version: '>=1.6.1' }],
#     postgres: [{ name: 'psycopg2_binary', version: '>=2.7.4' }],
#     s3: [{ name: 'boto', version: '>=2.36.0' },
#          { name: 'filechunkio', version: '>=1.6' }],
#     salesforce: [{name: 'simple-salesforce', version: '>=0.72'}],
#     samba: [{ name: 'pysmbclient', version: '>=0.1.3' }],
#     slack: [{ name: 'slackclient', version: '>=1.0.0' }],
#     ssh: [{ name: 'paramiko', version: '>=2.1.1' }],
#     statsd: [{ name: 'statsd', version: '>=3.0.1, <4.0' }],
#     vertica: [{ name: 'vertica-python', version: '>=0.5.1' }],
#     ldap: [{ name: 'ldap3', version: '>=0.9.9.1' }],
#     kerberos: [{ name: 'pykerberos', version: '>=1.1.8' },
#                { name: 'requests_kerberos', version: '>=0.10.0' },
#                { name: 'thrift_sasl', version: '>=0.2.0' },
#                { name: 'kerberos', version: '>=1.2.5' },
#                { name: 'snakebite[kerberos]', version: '>=2.7.8' }],
#     password: [{ name: 'bcrypt', version: '>=2.0.0' },
#                { name: 'flask-bcrypt', version: '>=0.7.1' }],
#     github_enterprise: [{ name: 'Flask-OAuthlib', version: '>=0.9.1' }],
#     qds: [{ name: 'qds-sdk', version: '>=1.9.6' }],
#     redis: [{ name: 'redis', version: '>=2.10.5'}],
#     cloudant: [{ name: 'cloudant', version: '>=0.5.9,<2.0' }],
#     devel: [{ name: 'click', version: '' },
#             { name: 'freezegun', version: '' },
#             { name: 'jira', version: '' },
#             { name: 'lxml', version: '>=3.3.4' },
#             { name: 'mock', version: '' },
#             { name: 'moto', version: '==1.1.19' },
#             { name: 'nose', version: '' },
#             { name: 'nose-ignore-docstring', version: '==0.2' },
#             { name: 'nose-timer', version: '' },
#             { name: 'parameterized', version: '' },
#             { name: 'rednose', version: '' },
#             { name: 'paramiko', version: '' },
#             { name: 'requests_mock', version: '' }],
#     winrm: [{ name: 'pywinrm', version: '>=0.3.0, <0.3.1'}]
#   }

# OS packages needed for the above python packages.
default['airflow']['dependencies'] =
  {
    ubuntu:
    {
      default: [{ name: 'python-dev', version: '' },
                { name: 'build-essential', version: '' },
                { name: 'libssl-dev', version: '' }],
      mysql: [{ name: 'mysql-client', version: '' },
              { name: 'libmysqlclient-dev', version: '' }],
      postgres: [{ name: 'postgresql-client', version: '' },
                 { name: 'libpq-dev', version: '' }],
      mssql: [{ name: 'freetds-dev', version: '' }],
      crypto: [{ name: 'libffi-dev', version: '' }],
      password: [{ name: 'libffi-dev', version: '' }],
      gcp_api: [{ name: 'libffi-dev', version: '' }],
      ldap: [{ name: 'libldap2-dev', version: '' }],
      hive: [{ name: 'libsasl2-dev', version: '' }],
      devel_hadoop: [{ name: 'libkrb5-dev', version: '' }],
      webhdfs: [{ name: 'libkrb5-dev', version: '' }],
      kerberos: [{ name: 'libsasl2-dev', version: '' }]
    },
    centos:
    {
      default: [{ name: 'gcc', version: '' },
                { name: 'gcc-c++', version: '' },
                { name: 'epel-release', version: '' },
                { name: 'libjpeg-devel', version: '' },
                { name: 'zlib-devel', version: '' },
                { name: 'python-devel', version: '' }],
      mysql: [{ name: 'mariadb', version: '' },
              { name: 'mariadb-devel', version: '' }],
      postgres: [{ name: 'postgresql', version: '' },
                 { name: 'postgresql-devel', version: '' }],
      mssql: [{ name: 'freetds-devel', version: '' }],
      crypto: [{ name: 'libffi-devel', version: '' }],
      password: [{ name: 'libffi-devel', version: '' }],
      gcp_api: [{ name: 'libffi-devel', version: '' }],
      ldap: [{ name: 'cyrus-sasl-devel', version: '' }],
      hive: [{ name: 'cyrus-sasl-devel', version: '' }],
      devel_hadoop: [{ name: 'cyrus-sasl-devel', version: '' }],
      webhdfs: [{ name: 'cyrus-sasl-devel', version: '' }],
      kerberos: [{ name: 'cyrus-sasl-devel', version: '' }]
    }
  }
