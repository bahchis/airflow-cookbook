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

property :packages, String, default: "all_dbs,async,devel_hadoop,celery,crypto,druid,gcp_api,jdbc,hdfs,hive,kerberos,ldap,mssql,mysql,password,postgres,qds,rabbitmq,s3,samba,slack,vertica,cloudant"

dependencies = {
					:ubuntu => {
						:default => [
							"python-dev", "build-essential", "libssl-dev"
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
						],
						:password => [
							"libffi-dev"
						],
						:gcp_api => [
							"libffi-dev"
						],
						:ldap => [
							"libldap2-dev"
						],
						:hive => [
							"libsasl2-dev"
						],
						:devel_hadoop => [
							"libkrb5-dev"
						]
					},
					:centos => {
						:default => [
							"gcc", "gcc-c++", "epel-release", "python-pip", "python-devel"
						],
						:mysql => [
							"mariadb", "mariadb-devel"
						],
						:postgres => [
							"postgresql", "postgresql-devel"
						],
						:mssql => [
							"freetds-devel"
						],
						:crypto => [
							"libffi-devel"
						],
						:password => [
							"libffi-devel"
						],
						:gcp_api => [
							"libffi-devel"
						],
						:ldap => [
							"cyrus-sasl-devel"
						],
						:hive => [
							"cyrus-sasl-devel"
						],
						:devel_hadoop => [
							"cyrus-sasl-devel"
						]
					}
				}

action :install do
	include_recipe "python"

	airflow_packages = packages.split(",")
	platform = node[:platform].to_sym

	dependencies_to_install = {}
	dependencies[platform][:default].each do |dependency|
		dependencies_to_install[dependency.to_sym] = true
	end

	if(airflow_packages.include?("all") || airflow_packages.include?("oracle"))
		raise ArgumentError, "Sorry, currently all, devel and oracle airflow pip packages are not supported in this cookbook. For more info, please see the README.md file."
	end

	# Map dependencies to install
	airflow_packages.each do |package| 
		package_key = package.to_sym

		dependencies[platform][package_key].each do |dependency|
			dependencies_to_install[dependency.to_sym] = true
		end if dependencies[platform].has_key?(package_key)			
	end	
	

	dependencies_to_install.each do |dependency, _|
		package dependency.to_s do
		  action	:install
		end
	end

	python_pip "airflow"

	airflow_packages.each do |package|
		python_pip "airflow[#{package}]"
	end

end
