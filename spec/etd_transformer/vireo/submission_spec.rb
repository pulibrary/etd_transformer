# frozen_string_literal: true

RSpec.describe EtdTransformer::Vireo::Submission do
  let(:vireo_export_directory) { "#{$fixture_path}/mock-downloads" }
  let(:ve_department_name) { 'German' }
  let(:ve) { EtdTransformer::Vireo::Export.new(ve_department_name) }
  let(:dataspace_import_directory) { "#{$fixture_path}/mock-exports" }
  let(:ve_asset_directory) { "#{vireo_export_directory}/#{ve_department_name}" }
  let(:submission) do
    submission = nil
    ve.metadata.simple_rows.each_with_index do |row, index|
      next if index.zero? # skip the header row
      next unless row['Status'] == 'Approved'

      submission = described_class.new(vireo_export: ve, row: row)
      break
    end
    submission
  end

  around do |example|
    vireo_export_dir_pre_test = ENV['VIREO_EXPORT_DIRECTORY']
    dataspace_import_dir_pre_test = ENV['DATASPACE_IMPORT_DIRECTORY']
    ENV['VIREO_EXPORT_DIRECTORY'] = vireo_export_directory
    ENV['DATASPACE_IMPORT_DIRECTORY'] = dataspace_import_directory
    example.run
    ENV['VIREO_EXPORT_DIRECTORY'] = vireo_export_dir_pre_test
    ENV['DATASPACE_IMPORT_DIRECTORY'] = dataspace_import_dir_pre_test
  end

  it 'gets data from a row from Excel' do
    expect(submission.row).to be_instance_of(Hash)
    expect(submission.student_id).to eq '961251996'
    expect(submission.student_name).to eq 'Cheon, Janice'
    expect(submission.primary_document).to eq 'http://thesis-central.princeton.edu//submit/review/1584978277IgrBDmmfiXo/8297/CHEON-JANICE-THESIS.pdf'
    expect(submission.id).to eq '8234'
  end

  it 'finds the original pdf document' do
    expect(submission.original_pdf).to eq 'CHEON-JANICE-THESIS.pdf'
  end

  it 'has a Vireo::Export from which to get file locations' do
    expect(submission.vireo_export_directory).to eq ve.vireo_export_directory
  end

  it 'knows what directory its original_pdf should be in' do
    location = "#{vireo_export_directory}/#{ve_department_name}/submission_#{submission.id}"
    expect(submission.source_files_directory).to eq location
  end

  xit 'ensures the original pdf document exists' do
    expect(submission.original_pdf_exists?).to eq true
  end
end
