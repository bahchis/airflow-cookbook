# Airflow Chef Cookbook

Installs and configures Airflow workflow management platform. More information about Airflow can be found here: https://github.com/airbnb/airflow

## Supported Platforms

Ubuntu (Tested on ubuntu 14.04).
Planned to support Centos soon.

## Recipes

-  - Installs and configures Airflow.
- webserver - Configures service for webserver using upstart.
- scheduler - Configures service for scheduler using upstart.

## Resource

- airflow - Used by the  recipe for installing and configuring Airflow.

## Attributes

### Default 

##### User config
["airflow"]["user"] - The user Airflow is executed with and owner of all related folders.
["airflow"]["group"] - Airflow user group.
["airflow"]["user_uid"] - Airflow user uid
["airflow"]["group_gid"] - Airflow group gid
["airflow"]["user_home_directory"] - Airflow user home directory.
["airflow"]["shell"] - Airflow user shell.

##### General config
["airflow"]["directories_mode"] - The permissions airflow and user directories are created.
["airflow"]["config_file_mode"] - The permissions airflow.cfg is created.
["airflow"]["log_path"] - Log files base directory.
["airflow"]["run_path"] - Pid files base directory

##### Core config
["airflow"]["config"]["core"]["airflow_home"] - Airflow home direcotory.
["airflow"]["config"]["core"]["dags_folder"] - Airflow dags directory.
["airflow"]["config"]["core"]["plugins_folder"] - Airflow plugins directory.
["airflow"]["config"]["core"]["sql_alchemy_conn"] - Sql Alchemy connection url.
["airflow"]["config"]["core"]["executor"] - Airflow executor.
["airflow"]["config"]["core"]["parallelism"] - Executoer maximum tasks in parallel.
["airflow"]["config"]["core"]["load_examples"] - wherther to load examples.
["airflow"]["config"]["core"]["fernet_key"] - Key for saving connections password in DB.

##### Webserver config
["airflow"]["config"]["webserver"]["web_server_host"] - Webserver host in config.
["airflow"]["config"]["webserver"]["web_server_port"] - Webserver port in config.
["airflow"]["config"]["webserver"]["base_url"] - Webserver URL.
["airflow"]["config"]["webserver"]["secret_key"] - Secret flask key.
["airflow"]["config"]["webserver"]["expose_config"] - Whether expose config in webserver.
["airflow"]["config"]["webserver"]["authenticate"] - Whether to authentificate user on webserver.
["airflow"]["config"]["webserver"]["filter_by_owner"] - Filter dags by owner name.

##### Scheduler config
["airflow"]["config"]["scheduler"]["job_heartbeat_sec"] - Seconds to listen for CLI kill signal.
["airflow"]["config"]["scheduler"]["scheduler_heartbeat_sec"] - How ofen scheuler runs to trigger new tasks.

##### Celery config
["airflow"]["config"]["celery"]["celery_app_name"] - Celery app name.
["airflow"]["config"]["celery"]["celeryd_concurrency"] - Worker concurrent tasks.
["airflow"]["config"]["celery"]["worker_log_server_port"] - Worker log webserver port.
["airflow"]["config"]["celery"]["broker_url"] - Celery broker url.
["airflow"]["config"]["celery"]["celery_result_backend"] - Celery backend URL.
["airflow"]["config"]["celery"]["flower_port"] - Flower port.
["airflow"]["config"]["celery"]["default_queue"] - The default queue to assignment and workers listening on.

### Webserver

["airflow"]["service"]["webserver"]["hostname"] - The host name webserver service will be lunched with as argument.
["airflow"]["service"]["webserver"]["port"] - The port name webserver service will be lunched with as argument.

### Scheduler

["airflow"]["service"]["scheduler"]["dags_folder"] - The dags folder path scheduler service will be lunched with as argument.

## Usage

Please see kitchen.yml for examples.

## License
Apache 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

## Author
Sergey Bahchissaraitsev