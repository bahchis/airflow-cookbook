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

name             'airflow'
maintainer       'Sergey Bahchissaraitsev'
maintainer_email 'info@bahchis.com'
license          'Apache v2.0'
description      'Installs and configures Airflow workflow management platform.'
long_description 'Installs and configures Airflow workflow management platform. More information about Airflow can be found here: https://github.com/airbnb/airflow'
source_url       'https://github.com/bahchis/airflow-cookbook'
issues_url       'https://github.com/bahchis/airflow-cookbook/issues'
version          '1.2.1'
supports         'ubuntu', '>= 14.04'
supports         'centos', '>= 7.0'
chef_version     '>12'

depends 'apt'
depends 'poise-python'
