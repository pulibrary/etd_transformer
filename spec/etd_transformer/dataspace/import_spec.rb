# frozen_string_literal: true

RSpec.describe EtdTransformer::Dataspace::Import do
  let(:di_department_name) { 'German' }
  let(:di) { described_class.new(di_department_name) }
  let(:vireo_export_directory) { "#{$fixture_path}/mock-downloads" }
  let(:dataspace_import_directory) { "#{$fixture_path}/mock-exports" }

  around do |example|
    vireo_export_dir_pre_test = ENV['VIREO_EXPORT_DIRECTORY']
    dataspace_import_dir_pre_test = ENV['DATASPACE_IMPORT_DIRECTORY']
    ENV['VIREO_EXPORT_DIRECTORY'] = vireo_export_directory
    ENV['DATASPACE_IMPORT_DIRECTORY'] = dataspace_import_directory
    example.run
    ENV['VIREO_EXPORT_DIRECTORY'] = vireo_export_dir_pre_test
    ENV['DATASPACE_IMPORT_DIRECTORY'] = dataspace_import_dir_pre_test
  end

  it 'has a department' do
    expect(di).to be_instance_of(described_class)
    expect(di.department_name).to eq di_department_name
  end
end
