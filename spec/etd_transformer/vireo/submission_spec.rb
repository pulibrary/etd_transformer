# frozen_string_literal: true

RSpec.describe EtdTransformer::Vireo::Submission do
  let(:input_dir) { "#{$fixture_path}/mock-downloads/German" }
  let(:ve_department_name) { 'German' }
  let(:ve) { EtdTransformer::Vireo::Export.new(input_dir) }
  let(:export_dir) { "#{$fixture_path}/exports" }
  let(:submission) do
    submission = nil
    ve.metadata.simple_rows.each_with_index do |row, index|
      next if index.zero? # skip the header row
      next unless row['Status'] == 'Approved'

      submission = described_class.new(asset_directory: ve.asset_directory, row: row)
      break
    end
    submission
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
    expect(submission.asset_directory).to eq ve.asset_directory
  end

  it 'knows what directory its original_pdf should be in' do
    location = "#{ve.asset_directory}/DSpaceSimpleArchive/submission_#{submission.id}"
    expect(submission.source_files_directory).to eq location
  end

  it 'ensures the original pdf document exists' do
    expect(submission.original_pdf_exists?).to eq true
  end

  it 'knows the full path of the original_pdf' do
    full_path = "#{ve.asset_directory}/DSpaceSimpleArchive/submission_8234/CHEON-JANICE-THESIS.pdf"
    expect(submission.original_pdf_full_path).to eq full_path
  end
end
