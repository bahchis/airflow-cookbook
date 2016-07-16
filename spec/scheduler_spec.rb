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

describe 'airflow::scheduler' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'creates scheduler service template' do
    expect(chef_run).to create_template('/etc/init/airflow-scheduler.conf')
  end

  it 'Starts and enables scheduler service' do
    expect(chef_run).to enable_service('airflow-scheduler')
    expect(chef_run).to start_service('airflow-scheduler')
  end
end