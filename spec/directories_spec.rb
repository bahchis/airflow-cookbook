require 'spec_helper'

describe 'airflow::directories' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'creates airflow home' do
    expect(chef_run).to create_directory('/usr/local/lib/airflow')
  end

  it 'creates dags folder' do
    expect(chef_run).to create_directory('/usr/local/lib/airflow/dags')
  end

  it 'creates plugins folder' do
    expect(chef_run).to create_directory('/usr/local/lib/airflow/plugins')
  end

  it 'creates log folder' do
    expect(chef_run).to create_directory('/var/log/airflow')
  end

  it 'creates run folder' do
    expect(chef_run).to create_directory('/var/run/airflow')
  end
end