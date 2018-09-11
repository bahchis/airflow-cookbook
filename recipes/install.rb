include_recipe "apt::default"

include_recipe "airflow::user"
include_recipe "airflow::directories"
include_recipe "airflow::packages"


