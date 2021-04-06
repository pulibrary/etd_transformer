# frozen_string_literal: true

RSpec.describe EtdTransformer::Vireo::Submission do
  let(:vireo_export_directory) { "#{$fixture_path}/mock-downloads" }
  let(:ve_department_name) { 'German' }
  let(:ve) { EtdTransformer::Vireo::Export.new(ve_department_name) }
  let(:dataspace_import_directory) { "#{$fixture_path}/mock-exports" }
  let(:ve_asset_directory) { "#{vireo_export_directory}/#{ve_department_name}" }

  around do |example|
    vireo_export_dir_pre_test = ENV['VIREO_EXPORT_DIRECTORY']
    dataspace_import_dir_pre_test = ENV['DATASPACE_IMPORT_DIRECTORY']
    ENV['VIREO_EXPORT_DIRECTORY'] = vireo_export_directory
    ENV['DATASPACE_IMPORT_DIRECTORY'] = dataspace_import_directory
    example.run
    ENV['VIREO_EXPORT_DIRECTORY'] = vireo_export_dir_pre_test
    ENV['DATASPACE_IMPORT_DIRECTORY'] = dataspace_import_dir_pre_test
  end

  it 'has a row from Excel' do
    submission = nil
    ve.metadata.simple_rows.each_with_index do |row, index|
      next if index.zero? # skip the header row
      next unless row['Status'] == 'Approved'

      submission = EtdTransformer::Vireo::Submission.new(row)
      break
    end
    expect(submission.row).to be_instance_of(Hash)
  end
end
