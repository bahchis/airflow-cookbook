require 'spec_helper'

describe 'airflow::webserver' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'creates webserver service template' do
    expect(chef_run).to create_template('/etc/init/airflow-webserver.conf')
  end

  it 'Starts and enables webserver service' do
    expect(chef_run).to enable_service('airflow-webserver')
    expect(chef_run).to start_service('airflow-webserver')
  end
end