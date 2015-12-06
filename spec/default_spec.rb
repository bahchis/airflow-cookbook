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

  it 'run airflow initdb' do 
    expect(chef_run).to run_bash('airflow_initdb').with({
        code: "/usr/local/bin/airflow initdb"
      });
  end
end