include_recipe "apt::default"

group node["airflow"]["group"] do
  gid node["airflow"]["group_gid"]
end

user node["airflow"]["user"] do
  comment "Airflow user"
  uid node["airflow"]["user_uid"]
  gid node["airflow"]["group_gid"]
  home node["airflow"]["user_home_directory"]
  manage_home true
  shell node["airflow"]["shell"]
end



directory node["airflow"]["config"]["core"]["airflow_home"] do
  owner node["airflow"]["user"]
  group node["airflow"]["group"]
  mode node["airflow"]["directories_mode"]
  action :create
end

directory node["airflow"]["config"]["core"]["dags_folder"] do
  owner node["airflow"]["user"]
  group node["airflow"]["group"]
  mode node["airflow"]["directories_mode"]
  action :create
end

directory node["airflow"]["config"]["core"]["plugins_folder"] do
  owner node["airflow"]["user"]
  group node["airflow"]["group"]
  mode node["airflow"]["directories_mode"]
  action :create
end

directory node["airflow"]["run_path"] do
  owner node["airflow"]["user"]
  group node["airflow"]["group"]
  mode node["airflow"]["directories_mode"]
  action :create
end




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



