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