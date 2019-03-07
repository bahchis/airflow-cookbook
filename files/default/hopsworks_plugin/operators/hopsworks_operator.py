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

import os

from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from airflow.contrib.operators.sqoop_operator import SqoopOperator

from hopsworks_plugin.hooks.hopsworks_hook import HopsworksHook

class HopsworksLaunchOperator(BaseOperator):
    """
    Basic operator to launch jobs on Hadoop through Hopsworks
    Jobs should have already been created in Hopsworks

    :param job_name: Name of the job in Hopsworks
    :type job_name: str
    :param project_id: Hopsworks Project ID this job is associated with
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
            **kwargs):
        super(HopsworksLaunchOperator, self).__init__(**kwargs)
        self.hopsworks_conn_id = hopsworks_conn_id
        self.job_name = job_name
        self.project_id = project_id
        self.project_name = project_name

    def _get_hook(self):
        return HopsworksHook(self.hopsworks_conn_id, self.project_id, self.project_name, self.owner)

    def execute(self, context):
        hook = self._get_hook()
        self.log.debug("Launching job %s", self.job_name)
        hook.launch_job(self.job_name)


class HopsworksSqoopOperator(SqoopOperator):
    """
    Operator to run Sqoop jobs. It configures some environment
    variables necessary for Sqoop to run in Hopsworks and
    MapReduce staging directory to a Project's directory

    :param project_id: Hopsworks Project ID this job is associated with
    :type project_id: int
    :param project_name: Hopsworks Project name this job is associated with
    :type project_name: str
    """
    
    PROJECT_STAGING = '/Projects/{project_name}/Resources/.mrStaging'
    
    @apply_defaults
    def __init__(self, hopsworks_conn_id = 'hopsworks_default',
                 project_id = None,
                 project_name = None,
                 *args,
                 **kwargs):
        super(HopsworksSqoopOperator, self).__init__(*args, **kwargs)
        self.hopsworks_conn_id = hopsworks_conn_id
        self.project_id = project_id
        self.project_name = project_name
    
    def execute(self, context):
        self.log.debug("Preparing Sqoop job")
        hook = HopsworksHook(self.hopsworks_conn_id, self.project_id, self.project_name, self.owner)
        if self.project_name is None:
            self.project_name = hook.project_name

        project_specific_user = "{0}__{1}".format(self.project_name, self.owner)
        # Set impersonation
        os.environ['HADOOP_USER_NAME'] = project_specific_user

        # Generate secret dir and export MATERIAL_DIRECTORY
        secret_dir = hook._generate_secret_dir()
        os.environ['MATERIAL_DIRECTORY'] = secret_dir

        # Set per project staging directory
        staging_dir = HopsworksSqoopOperator.PROJECT_STAGING.format(project_name=self.project_name)
        self.properties = {} if self.properties is None else self.properties
        self.properties['yarn.app.mapreduce.am.staging-dir'] = staging_dir
        self.properties['yarn.app.mapreduce.client.max-retries'] = 10
        
        self.log.debug("Calling SqoopOperator")
        super(HopsworksSqoopOperator, self).execute(context)
