require 'spec_helper'

describe 'airflow::user' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'creates airflow user' do
    expect(chef_run).to create_user('airflow')
  end

  it 'creates airflow group' do
    expect(chef_run).to create_group('airflow')
  end
end