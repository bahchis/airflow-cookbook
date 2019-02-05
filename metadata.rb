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

name             'hops_airflow'
maintainer       'Sergey Bahchissaraitsev'
maintainer_email 'info@bahchis.com'
license          'Apache v2.0'
description      'Installs and configures Airflow workflow management platform.'
long_description 'Installs and configures Airflow workflow management platform. More information about Airflow can be found here: https://github.com/airbnb/airflow'
source_url       'https://github.com/bahchis/airflow-cookbook'
issues_url       'https://github.com/bahchis/airflow-cookbook/issues'
version          '1.2.2'
supports         'ubuntu', '>= 14.04'
supports         'centos', '>= 7.0'
chef_version     '>=12.1'

depends 'apt'
depends 'poise-python'
depends 'kagent'
depends 'ndb'
depends 'java'
depends 'hops'

recipe           "default", "Configures an Airflow Server"
recipe           "install", "Installs an Airflow Server"
recipe           "sqoop", "Installs and onfigures Sqoop and the Sqoop metastore service"
recipe           "purge", "Removes and deletes an installed Airflow Server"

attribute "airflow/dir",
          :description => "Installation directory for the airflow binaries/config files",
          :type => 'string'

attribute "airflow/user",
          :description => "Airflow username to run service as",
          :type => 'string'

attribute "airflow/group",
          :description => "Airflow group to run service as",
          :type => 'string'

attribute "airflow/mysql_user",
          :description => "Airflow database username",
          :type => 'string'

attribute "airflow/mysql_password",
          :description => "Airflow database password",
          :type => 'string'

attribute "airflow/operators",
          :description => "Comma-separated list of airflow operators to install by default. E.g., 'hdfs, hive, mysql, password'",
          :type => 'string'

attribute "airflow/scheduler_runs",
          :description => "Number of runs to execute before the scheduler is restarted",
          :type => 'string'

attribute "sqoop/dir",
          :description => "Installation directory for the sqoop binaries/config files",
          :type => 'string'

attribute "sqoop/user",
          :description => "Sqoop username to run service as",
          :type => 'string'

attribute "sqoop/group",
          :description => "Sqoop group to run service as",
          :type => 'string'

attribute "sqoop/port",
          :description => "Sqoop metastore port",
          :type => 'string'

