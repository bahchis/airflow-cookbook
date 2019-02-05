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
    EOH
  not_if "#{exec} -e 'show databases' | grep airflow"	
end
