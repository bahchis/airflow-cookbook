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
import sys
import hashlib
import requests

from requests import exceptions as requests_exceptions
from requests.auth import AuthBase

from airflow.hooks.base_hook import BaseHook
from airflow.utils.log.logging_mixin import LoggingMixin
from airflow.exceptions import AirflowException
from airflow import configuration
from airflow.models import Connection

PY3 = sys.version_info[0] == 3

if PY3:
    from urllib import parse as urlparse
else:
    import urlparse
    
AIRFLOW_HOME_ENV = "AIRFLOW_HOME"
JWT_FILE_SUFFIX = ".jwt"

RUN_JOB = ("POST", "hopsworks-api/api/project/{project_id}/jobs/{job_name}/executions?action=start")
# Get the latest execution
JOB_STATE = ("GET", "hopsworks-api/api/project/{project_id}/jobs/{job_name}/executions?sort_by=appId:desc&limit=1")

class HopsworksHook(BaseHook, LoggingMixin):
    """
    Hook to interact with Hopsworks

    :param hopsworks_conn_id: The name of Hopsworks connection to use.
    :type hopsworks_conn_id: str
    :param project_id: The project ID the job is associated with.
    :type project_id: int
    :param owner: Hopsworks username
    :type owner: str
    """
    def __init__(self, hopsworks_conn_id='hopsworks_default', project_id=None, owner=None):
        self.hopsworks_conn_id = hopsworks_conn_id
        self.project_id = project_id
        self.owner = owner
        self.hopsworks_conn = self.get_connection(hopsworks_conn_id)
        self._get_airflow_home()

    def get_connection(self, connection_id):
        hopsworks_host = configuration.conf.get("webserver", "hopsworks_host")
        hopsworks_port = configuration.conf.getint("webserver", "hopsworks_port")
        return Connection(conn_id=connection_id,
                          host=self._parse_host(hopsworks_host),
                          port=hopsworks_port)
    
    def launch_job(self, job_name):
        """
        Function for launching a job to Hopsworks. The call does not wait for job
        completion, use HopsworksSensor for this purpose.
        
        :param job_name: Name of the job to be launched in Hopsworks
        :type job_name: str
        """
        method, endpoint = RUN_JOB
        endpoint = endpoint.format(project_id=self.project_id, job_name=job_name)
        response = self._do_api_call(method, endpoint)

    def get_job_state(self, job_name):
        """
        Function to get the state of a job

        :param job_name: Name of the job in Hopsworks
        :type job_name: str
        """
        method, endpoint = JOB_STATE
        endpoint = endpoint.format(project_id=self.project_id, job_name=job_name)
        response = self._do_api_call(method, endpoint)
        item = response['items'][0]
        return item['state']
        
    def _do_api_call(self, method, endpoint):
        jwt = self._parse_jwt_for_user()
        url = "https://{host}:{port}/{endpoint}".format(
            host = self.hopsworks_conn.host,
            port = self.hopsworks_conn.port,
            endpoint = endpoint)
        auth = AuthorizationToken(jwt)
        if "GET" == method:
            requests_method = requests.get
        elif "POST" == method:
            requests_method = requests.post
        else:
            raise AirflowException("Unexpected HTTP method: " + method)

        try:
            # Until we find a better approach to load trust anchors and
            # bypass hostname verification, disable verify
            response = requests_method(url, auth=auth, verify=False)
            response.raise_for_status()
            return response.json()
        except requests_exceptions.SSLError as ex:
            raise AirflowException(ex)
        except requests_exceptions.RequestException as ex:
            raise AirflowException("Error making HTTP request. Response: {0} - Status Code: {1}"
                                   .format(ex.response.content, ex.response.status_code))
            
    def _parse_host(self, host):
        """
        Host should be just the hostname or ip address
        Remove protocol or any endpoints from the host

        """
        parsed_host = urlparse.urlparse(host).hostname
        if parsed_host:
            # Host contains protocol
            return parsed_host
        return host

    def _get_airflow_home(self):
        """
        Discover Airflow home. Environment variable takes precedence over configuration
        """
        if AIRFLOW_HOME_ENV in os.environ:
            return os.environ[AIRFLOW_HOME_ENV]
        airflow_home = configuration.conf.get("core", "airflow_home")
        if not airflow_home:
            raise AirflowException("Airflow home is not set in configuration, nor in $AIRFLOW_HOME")
        return airflow_home

    def _generate_secret_dir(self):
        """
        Generate the secret project directory where the JWT file should be located
        """
        if not self.project_id:
            raise AirflowException("Hopsworks Project ID is not set")
        return hashlib.sha256(str(self.project_id).encode('UTF-8')).hexdigest()

    def _parse_jwt_for_user(self):
        """
        Read JWT for the user from the secret project directory.

        WARNING: JWT is renewed automatically by Hopsworks, so caching
        will break things!!!
        """
        if not self.owner:
            raise AirflowException("Owner of the DAG is not specified")
        
        airflow_home = self._get_airflow_home()
        secret_dir = self._generate_secret_dir()
        filename = self.owner + JWT_FILE_SUFFIX
        jwt_token_file = os.path.join(airflow_home, "secrets", secret_dir, filename)

        if not os.path.isfile(jwt_token_file):
            raise AirflowException('Could not read JWT file for user {}'.format(self.owner))
        with open(jwt_token_file, 'r') as fd:
            return fd.read().strip()

class AuthorizationToken(AuthBase):
    def __init__(self, token):
        self.token = token

    def __call__(self, request):
        request.headers['Authorization'] = "Bearer " + self.token
        return request
