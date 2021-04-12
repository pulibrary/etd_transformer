# frozen_string_literal: true

RSpec.describe EtdTransformer::Dataspace::Submission do
  let(:di_department_name) { 'German' }
  let(:di) { EtdTransformer::Dataspace::Import.new(di_department_name) }
  let(:ds) { described_class.new(di, '8234') }
  let(:dataspace_import_base) { "#{$fixture_path}/mock-exports" }

  around do |example|
    dataspace_import_base_pre_test = ENV['DATASPACE_IMPORT_BASE']
    ENV['DATASPACE_IMPORT_BASE'] = dataspace_import_base
    example.run
    ENV['DATASPACE_IMPORT_BASE'] = dataspace_import_base_pre_test
  end

  it 'can be instantiated' do
    expect(ds).to be_instance_of(described_class)
  end
  it 'has a Dataspace::Import object' do
    expect(ds.dataspace_import).to be_instance_of(EtdTransformer::Dataspace::Import)
  end
  it 'has an id' do
    expect(ds.id).to eq '8234'
  end
  it 'makes a directory for itself' do
    expect(ds.directory_path).to eq "#{di.dataspace_import_directory}/submission_#{ds.id}"
  end
end
