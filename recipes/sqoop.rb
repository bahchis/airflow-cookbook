include_recipe "java"

my_ip = my_private_ip()

hops_groups()

group node['sqoop']['group'] do
  action :create
  not_if "getent group #{node['sqoop']['group']}"
end

user node['sqoop']['user'] do
  home "/home/#{node['sqoop']['user']}"
  gid node['sqoop']['group']
  action :create
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node['sqoop']['user']}"
end

group node['kagent']['certs_group'] do
  action :modify
  members ["#{node['sqoop']['user']}"]
  append true
end

group node['hops']['group'] do
  action :modify
  members ["#{node['sqoop']['user']}"]
  append true
end

group node['sqoop']['group'] do
  action :modify
  members ["#{node['airflow']['user']}"]
  append true
end


package_url = "#{node['sqoop']['url']}"
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config['file_cache_path']}/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "#{node['sqoop']['user']}"
  mode "0644"
  action :create_if_missing
end

# Extract Sqoop
sqoop_downloaded = "#{node['sqoop']['home']}/.sqoop_extracted_#{node['sqoop']['version']}"

bash 'extract-sqoop' do
        user "root"
        group node['sqoop']['group']
        code <<-EOH
                set -e
                rm -rf #{node['sqoop']['base_dir']}
                tar -xf #{cached_package_filename} -C #{node['sqoop']['dir']}
                chown -R #{node['sqoop']['user']}:#{node['sqoop']['group']} #{node['sqoop']['home']}
                chmod 750 #{node['sqoop']['home']}
                touch #{sqoop_downloaded}
                chown -R #{node['sqoop']['user']}:#{node['sqoop']['group']} #{sqoop_downloaded}
        EOH
     not_if { ::File.exists?( "#{sqoop_downloaded}" ) }
end

link node['sqoop']['base_dir'] do
  owner node['sqoop']['user']
  group node['sqoop']['group']
  to node['sqoop']['home']
end

directory node['sqoop']['base_dir'] + "/log"  do
  owner node['sqoop']['user']
  group node['sqoop']['group']
  mode "750"
  action :create
end

exec = "#{node['ndb']['scripts_dir']}/mysql-client.sh"

bash 'create_sqoop_db' do
  user "root"
  code <<-EOF
      set -e
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS sqoop CHARACTER SET latin1\"
      #{exec} -e \"GRANT ALL PRIVILEGES ON sqoop.* TO '#{node['airflow']['mysql_user']}'@'localhost' IDENTIFIED BY '#{node['airflow']['airflow_password']}'\"
    EOF
  not_if "#{exec} -e 'show databases' | grep sqoop"
end



template "#{node['sqoop']['base_dir']}/conf/sqoop-site.xml" do
  source "sqoop-site.xml.erb"
  owner node['sqoop']['user']
  group node['sqoop']['group']
  mode 0750
  action :create
#  variables({
#              :influxdb_ip => influxdb_ip
#            })
end


service_name="sqoop"

service service_name do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

case node['platform_family']
when "rhel"
  systemd_script = "/usr/lib/systemd/system/#{service_name}.service"
else
  systemd_script = "/lib/systemd/system/#{service_name}.service"
end

template systemd_script do
  source "#{service_name}.service.erb"
  owner "root"
  group "root"
  mode 0754
  notifies :enable, resources(:service => service_name)
  notifies :start, resources(:service => service_name), :immediately
end

kagent_config service_name do
  action :systemd_reload
end

if node['kagent']['enabled'] == "true"
   kagent_config service_name do
     service "airflow"
     log_file "#{node['sqoop']['base_dir']}/log/sqoop-metastore-sqoop-localhost.log"
     web_port node['sqoop']['port'].to_i
   end
end

