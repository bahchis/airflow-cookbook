# Copyright 2015 Sergey Bahchissaraitsev

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http//www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe 'airflow::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'includes apt::default recipe' do
    expect(chef_run).to include_recipe('apt::default')
  end

  it 'includes airflow::user recipe' do
    expect(chef_run).to include_recipe('airflow::user')
  end

  it 'includes airflow::directories recipe' do
    expect(chef_run).to include_recipe('airflow::directories')
  end

  it 'creates airflow.cfg template' do
    expect(chef_run).to create_template('/usr/local/lib/airflow/airflow.cfg')
  end

  it 'run airflow system wide home variable' do 
    expect(chef_run).to run_bash('airflow_home_env')
  end

  it 'run airflow initdb' do 
    expect(chef_run).to run_bash('airflow_initdb').with({
        code: "/usr/local/bin/airflow initdb"
      });
  end
end