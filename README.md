# Airflow Chef Cookbook

Installs and configures Airflow workflow management platform. More information about Airflow can be found here: https://github.com/airbnb/airflow


## Supported Platforms

Ubuntu (Tested on 14.04, 16.04).
CentOS (Tested on 7.2).

## Limitations

The Airflow **all** and **oracle** packages are not supported, this is due the Oracle package having dependencies which cannot be automatically installed. I will look how to solve this and add support for those packages at later stage.

## Contributing

Please follow instructions in the [contributing doc](CONTRIBUTING.md).

## Usage

- Use the relevant cookbooks to install and configure Airflow.
- Use environment variable in /etc/default/airflow (for Ubuntu) or /etc/sysconfig/airflow (for CentOS) to configure Airflow during the startup process. (More info about Airflow environment variables at: [Setting Configuration Options](https://pythonhosted.org/airflow/configuration.html#setting-configuration-options))
- Make sure to run **airflow initdb** as part of your startup script.

## Recipes

- default - Executes other recipes.
- directories - Creates required directories.
- user - Creates OS user and group.
- packages - Installs OS and pip packages.
- config - Handles airflow.cfg
- services - Creates services env file.
- webserver - Configures service for webserver.
- scheduler - Configures service for scheduler.
- worker - Configures service for worker.
- flower - Configures service for flower.
- kerberos - Configures service for kerberos.
- packages - Installs Airflow and supporting packages. 

## Attributes
##### User config
- ["airflow"]["airflow_package"] - Airflow package name, defaults to 'apache-airflow'. Use 'airflow' for installing version 1.8.0 or lower.
- ["airflow"]["version"] - The version of airflow to install, defaults to latest (nil).
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
- ["airflow"]["is_upstart"] - Should upstart be used for services, determined automatiaclly.
- ["airflow"]["init_system"] - The init system to use when configuring services, only upstart or systemd are supported and defaults based on ["airflow"]["is_upstart"] value.
- ["airflow"]["env_path"] - The path to services env file, determined automatiaclly.

##### Python config
- ["airflow"]["python_runtime"] = Python runtime as used by [poise-python cookbook](https://github.com/poise/poise-python#quick-start). 
- ["airflow"]["python_version"] = Python version to install as used by poise-python cookbook.
- ["airflow"]["pip_version"] = Pip version to install (true - installs latest) as used by poise-python cookbook.

##### Package config
- default['airflow']['packages'] - The Python packages to install for Airflow.
- default['airflow']['dependencies'] - The dependencies of the packages listed in default['airflow']['packages']. These are OS packages, not Python packages. 

##### airflow.cfg
This cookbook enables to configure any airflow.cfg paramters dynamically by using attributes structure like (see the attributes file for [airflow.cfg examples](attributes/default.rb)):
["airflow"]["config"]["CONFIG_SECTION"]["CONFIG_ENTRY"]

## License
Apache 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

## Author
[Sergey Bahchissaraitsev](http://www.bahchis.com/about/)
