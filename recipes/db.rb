private_ip = my_private_ip()
fqdn = node['fqdn']
exec = "#{node['ndb']['scripts_dir']}/mysql-client.sh"

bash 'create_airflow_db' do	
  user "root"	
  code <<-EOH
      set -e	
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS airflow CHARACTER SET latin1\"	
      #{exec} -e \"GRANT ALL PRIVILEGES ON airflow.* TO '#{node['airflow']['mysql_user']}'@'#{private_ip}' IDENTIFIED BY '#{node['airflow']['mysql_password']}'\"
      #{exec} -e \"GRANT ALL PRIVILEGES ON airflow.* TO '#{node['airflow']['mysql_user']}'@'#{fqdn}' IDENTIFIED BY '#{node['airflow']['mysql_password']}'\"
      #{exec} -e \"GRANT ALL PRIVILEGES ON airflow.* TO '#{node['airflow']['mysql_user']}'@'127.0.0.1' IDENTIFIED BY '#{node['airflow']['mysql_password']}'\"
      #{exec} -e \"GRANT ALL PRIVILEGES ON airflow.* TO '#{node['airflow']['mysql_user']}'@'localhost' IDENTIFIED BY '#{node['airflow']['mysql_password']}'\"
    EOH
  not_if "#{exec} -e 'show databases' | grep airflow"	
end

cookbook_file "/home/#{node['airflow']['user']}/create_db_idx_proc.sql" do
  source 'create_db_idx_proc.sql'
  owner node['airflow']['user']
  group node['airflow']['group']
  mode 0500
  notifies :run, 'bash[import_create_idx_proc]', :immediately
end

bash 'import_create_idx_proc' do
  user "root"
  group "root"
  code <<-EOH
       set -e
       #{exec} < /home/#{node['airflow']['user']}/create_db_idx_proc.sql
       EOH
  only_if { ::File.exist?("/home/#{node['airflow']['user']}/create_db_idx_proc.sql") }
end
