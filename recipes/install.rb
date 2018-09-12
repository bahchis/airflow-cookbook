include_recipe "apt::default"

include_recipe "hops_airflow::user"
include_recipe "hops_airflow::directories"
include_recipe "hops_airflow::packages"


