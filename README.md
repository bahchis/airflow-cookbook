# Airflow Chef Cookbook

Installs and configures Airflow workflow management platform. More information about Airflow can be found here: https://github.com/airbnb/airflow


## Supported Platforms

Ubuntu (Tested on 14.04).
CentOS (Tested on 7.2).

## Limitations

The Airflow **all** and **oracle** packages are not supported, this is due the Oracle package having dependencies which cannot be automatically installed. I will look how to solve this and add support for those packages at later stage.

## Usage

- Use the relevant cookbooks to install and configure Airflow.
- Use environment variable in /etc/default/airflow (for Ubuntu) or /etc/sysconfig/airflow (for CentOS) to configure Airflow during the startup process. (More info about Airflow environment variables at: [Setting Configuration Options](https://pythonhosted.org/airflow/configuration.html#setting-configuration-options))
- Make sure to run **airflow initdb** as part of your startup script.

## Recipes

- default - Installs and configures Airflow.
- webserver - Configures service for webserver.
- scheduler - Configures service for scheduler.
- worker - Configures service for worker.
- flower - Configures service for flower.
- kerberos - Configures service for kerberos.

## Resource

- airflow - Used by the default recipe for installing and configuring Airflow.

## Attributes

##### User config
- ["airflow"]["version"] = The version of airflow to install, defaults to latest (nil).
- ["airflow"]["user"] - The user Airflow is executed with and owner of all related folders.
- ["airflow"]["group"] - Airflow user group.
- ["airflow"]["user_uid"] - Airflow user uid
- ["airflow"]["group_gid"] - Airflow group gid
- ["airflow"]["user_home_directory"] - Airflow user home directory.
- ["airflow"]["shell"] - Airflow user shell.

##### General config
- ["airflow"]["directories_mode"] - The permissions airflow and user directories are created.
- ["airflow"]["config_file_mode"] - The permissions airflow.cfg is created.
- ["airflow"]["bin_path"] - Path to the bin folder, default is based on platform.
- ["airflow"]["run_path"] - Pid files base directory
- ["airflow"]["init_system"] - The init system to use when configuring services, only upstart or systemd are supported and defaults based on platfrom.

##### airflow.cfg
This cookbook enables to configure any airflow.cfg paramters dynamically by using attributes structure like (see the attributes file for [airflow.cfg examples](attributes/default.rb)):
["airflow"]["config"]["CONFIG_SECTION"]["CONFIG_ENTRY"]

## License
Apache 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

## Author
[Sergey Bahchissaraitsev](http://www.bahchis.com/about/)
