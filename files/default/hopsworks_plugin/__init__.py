from airflow.plugins_manager import AirflowPlugin

from hopsworks_plugin.hooks import HOPSWORKS_HOOKS
from hopsworks_plugin.operators import HOPSWORKS_OPERATORS
from hopsworks_plugin.sensors import HOPSWORKS_SENSORS

class HopsworksPlugin(AirflowPlugin):
    name = "hopsworks_plugin"
    hooks = HOPSWORKS_HOOKS
    operators = HOPSWORKS_OPERATORS
    sensors = HOPSWORKS_SENSORS
