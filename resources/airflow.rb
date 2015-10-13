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

resource_name :airflow

actions :install
default_action :install

property :packages, String, default: "crypto,mysql"

dependencies = {
	:all => [
		"libldap2-dev", "libsasl2-dev", "libssl-dev"
	],
	:default => [
		"python-dev", "build-essential"
	],
	:mysql => [
		"mysql-client", "libmysqlclient-dev"
	],
	:postgres => [
		"postgresql-client", "libpq-dev"
	],
	:mssql => [
		"freetds-dev"
	],
	:crypto => [
		"libffi-dev"
	]
}

action :install do
	include_recipe "python"

	airflow_packages = packages.split(",")

	if(airflow_packages.include?("all") || airflow_packages.include?("devel"))
		dependencies.each do |dependency_index,dependency_arr|
			log "airflow_#{dependency_index.to_s}_dependencies" do
			  message 'Installing #{dependency_index.to_s} dependencies.'
			  level :info
			end

			dependency_arr.each do |dependency|
				apt_package dependency do
				  action	:install
				end			
			end
		end
	else
		airflow_packages.unshift("default").each do |package| 
			dependency_key = package.to_sym

			log "airflow_#{package}_dependencies" do
			  message 'Installing #{package} dependencies.'
			  level :info
			end

			dependencies[dependency_key].each do |dependency|
				apt_package dependency do
				  action	:install
				end			
			end if dependencies.has_key?(dependency_key)
		end	
	end

	python_pip "airflow"

	airflow_packages.each do |package|
		python_pip "airflow[#{package}]"
	end

end
