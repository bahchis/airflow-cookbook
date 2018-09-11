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

python_runtime node["airflow"]["python_runtime"] do
  version node["airflow"]["python_version"]
  provider :system
  pip_version node["airflow"]["pip_version"]
end

# Obtain the current platform name
platform = node['platform'].to_s

# Default dependencies to install
dependencies_to_install = []
node['airflow']['dependencies'][platform][:default].each do |dependency|
  dependencies_to_install << dependency
end

# Get Airflow packages as strings
airflow_packages = []
node['airflow']['packages'].each do |key, _value|
  airflow_packages << key.to_s
end

# Use the airflow package strings to add dependent packages to install.
airflow_packages.each do |package|
  if node['airflow']['dependencies'][platform].key?(package.to_sym)
    node['airflow']['dependencies'][platform][package].each do |dependency|
      dependencies_to_install << dependency
    end
  end
end

if(airflow_packages.include?('all') || airflow_packages.include?('oracle'))
  raise ArgumentError, "Sorry, currently all, devel and oracle airflow pip packages are not supported in this cookbook. For more info, please see the README.md file."
end

# Install dependencies
dependencies_to_install.each do |value|
  package_to_install = ''
  version_to_install = ''
  value.each do |key, val|
    if key.to_s == 'name'
      package_to_install = val
    else
      version_to_install = val
    end
  end
  package package_to_install do
    action  :install
    version version_to_install
  end
end

# Install Airflow
python_package node['airflow']['airflow_package'] do
  version node['airflow']['version']
end

# Install Airflow packages
node['airflow']['packages'].each do |_key, value|
  value.each do |val|
    package_to_install = ''
    version_to_install = ''
    val.each do |k, v|
      if k.to_s == 'name'
        package_to_install = v
      else
        version_to_install = v
      end
    end
    python_package package_to_install.to_s do
      action :install
      version version_to_install.to_s
    end
  end
end
