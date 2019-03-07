# -*- coding: utf-8 -*-
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

from airflow.sensors.base_sensor_operator import BaseSensorOperator
from airflow.exceptions import AirflowException
from airflow.utils.decorators import apply_defaults

from hopsworks_plugin.hooks.hopsworks_hook import HopsworksHook

JOB_SUCCESS_FINAL_STATES = {'FINISHED'}

JOB_FAILED_FINAL_STATES = {'FAILED', 'KILLED', 'FRAMEWORK_FAILURE',
                           'APP_MASTER_START_FAILED', 'INITIALIZATION_FAILED'}

JOB_FINAL_STATES = JOB_FAILED_FINAL_STATES.union(JOB_SUCCESS_FINAL_STATES)

class HopsworksJobFinishSensor(BaseSensorOperator):
    """
    Sensor to wait for a job to finish regardless of the final state

    :param job_name: Name of the job in Hopsworks
    :type job_name: str
    :param project_id: Hopsworks Project ID the job is associated with
    :type project_id: int
    :param project_name: Hopsworks Project name this job is associated with
    :type project_name: str
    :param response_check: Custom function to check the return state
    :type response_check: function
    """

    @apply_defaults
    def __init__(
            self,
            hopsworks_conn_id = 'hopsworks_default',
            job_name = None,
            project_id = None,
            project_name = None,
            response_check = None,
            *args,
            **kwargs):
        super(HopsworksJobFinishSensor, self).__init__(*args, **kwargs)
        self.hopsworks_conn_id = hopsworks_conn_id
        self.job_name = job_name
        self.project_id = project_id
        self.project_name = project_name
        self.response_check = response_check

    def _get_hook(self):
        return HopsworksHook(self.hopsworks_conn_id, self.project_id, self.project_name, self.owner)

    def poke(self, context):
        hook = self._get_hook()
        state = hook.get_job_state(self.job_name)

        if self.response_check:
            return self.response_check(state)

        # If no check was defined, assume that any FINAL state is success
        return state.upper() in JOB_FINAL_STATES

    
class HopsworksJobSuccessSensor(BaseSensorOperator):
    """
    Sensor to wait for a successful completion of a job
    If the job fails, the sensor will fail

    :param job_name: Name of the job in Hopsworks
    :type job_name: str
    :param project_id: Hopsworks Project ID the job is associated with
    :type project_id: int
    :param project_name: Hopsworks Project name this job is associated with
    :type project_name: str
    """

    @apply_defaults
    def __init__(
            self,
            hopsworks_conn_id = 'hopsworks_default',
            job_name = None,
            project_id = None,
            project_name = None,
            poke_interval = 10,
            timeout = 3600,
            *args,
            **kwargs):
        super(HopsworksJobSuccessSensor, self).__init__(*args, **kwargs)
        self.hopsworks_conn_id = hopsworks_conn_id
        self.job_name = job_name
        self.project_id = project_id
        self.project_name = project_name

    def _get_hook(self):
        return HopsworksHook(self.hopsworks_conn_id, self.project_id, self.project_name, self.owner)

    def poke(self, context):
        hook = self._get_hook()
        state = hook.get_job_state(self.job_name)

        if state.upper() in JOB_FAILED_FINAL_STATES:
            raise AirflowException("Hopsworks job failed")
        
        return state.upper() in JOB_SUCCESS_FINAL_STATES
