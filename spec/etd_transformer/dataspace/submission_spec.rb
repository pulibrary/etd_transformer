# frozen_string_literal: true

RSpec.describe EtdTransformer::Dataspace::Submission do
  let(:di_department_name) { 'German' }
  let(:output_dir) { "#{$fixture_path}/exports" }
  let(:di) { EtdTransformer::Dataspace::Import.new(output_dir, di_department_name) }
  let(:ds) { described_class.new(di, '8234') }

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
    expect(ds.directory_path).to eq "#{di.output_dir}/#{di_department_name}/submission_#{ds.id}"
  end
end
