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

from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults

from hopsworks_plugin.hooks.hopsworks_hook import HopsworksHook

class HopsworksLaunchOperator(BaseOperator):
    """
    Basic operator to launch jobs on Hadoop through Hopsworks
    Jobs should have already been created in Hopsworks

    :param job_name: Name of the job in Hopsworks
    :type job_name: str
    :param project_id: Hopsworks Project ID this job is associated with
    :type project_id: int
    """

    @apply_defaults
    def __init__(
            self,
            hopsworks_conn_id = 'hopsworks_default',
            job_name = None,
            project_id = None,
            **kwargs):
        super(HopsworksLaunchOperator, self).__init__(**kwargs)
        self.hopsworks_conn_id = hopsworks_conn_id
        self.job_name = job_name
        self.project_id = project_id

    def _get_hook(self):
        return HopsworksHook(self.hopsworks_conn_id, self.project_id, self.owner)

    def execute(self, context):
        hook = self._get_hook()
        self.log.debug("Launching job %s", self.job_name)
        hook.launch_job(self.job_name)
