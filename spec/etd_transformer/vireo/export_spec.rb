# frozen_string_literal: true

RSpec.describe EtdTransformer::Vireo::Export do
  let(:input) { "#{$fixture_path}/mock-downloads/German" }
  let(:output) { "#{$fixture_path}/exports" }
  let(:ve_department_name) { 'German' }
  let(:ve) { described_class.new(input) }

  it 'has a department' do
    expect(ve).to be_instance_of(described_class)
    expect(ve.department_name).to eq 'German'
  end

  it 'knows what directory its assets are in' do
    expect(ve.asset_directory).to eq input
  end

  it 'finds and loads the spreadsheet' do
    expect(ve.metadata).to be_instance_of(Creek::Sheet)
    expect(ve.metadata.rows.count).to eq 8
  end

  context 'a spreadsheet with Excel problems' do
    context 'missing columns' do
      let(:spreadsheet_with_missing_columns) { "#{$fixture_path}/malformed_spreadsheets/missing_columns.xlsx" }
      it "raises a specific error with the missing column name" do
        expect { ve.check_spreadsheet_for_required_columns(spreadsheet_with_missing_columns) }.to raise_error EtdTransformer::Vireo::IncompleteSpreadsheetError
      end
    end
    context 'an id number with appended decimals' do
      let(:input) { "#{$fixture_path}/mock-downloads/Economics" }
      it "strips the extra zero" do
        expect(ve.approved_submissions.first[0]).to eq "9508" # Not 9508.0
        expect(ve.approved_submissions.first.last.id).to eq "9508"
      end
    end
  end

  context 'initial file setup' do
    let(:unzipped_path) { File.join(input, 'DSpaceSimpleArchive') }
    before do
      FileUtils.rm_rf(unzipped_path) if Dir.exist? unzipped_path
    end
    context 'without spaces in the path' do
      it 'unzips the file' do
        expect(Dir.exist?(unzipped_path)).to eq false
        ve.unzip_archive
        expect(Dir.exist?(unzipped_path)).to eq true
      end
    end
    context 'with spaces in the path' do
      let(:input) { "#{$fixture_path}/mock-downloads/African American Studies" }
      it 'unzips the file' do
        expect(Dir.exist?(unzipped_path)).to eq false
        ve.unzip_archive
        expect(Dir.exist?(unzipped_path)).to eq true
      end
    end
    context 'with escaped spaces in the path' do
      let(:input) { "#{$fixture_path}/mock-downloads/African\ American\ Studies" }
      it 'unzips the file' do
        expect(Dir.exist?(unzipped_path)).to eq false
        ve.unzip_archive
        expect(Dir.exist?(unzipped_path)).to eq true
      end
    end
  end

  context 'submissions' do
    it 'has a hash of approved submissions accessible by id' do
      expect(ve.approved_submissions).to be_instance_of(Hash)
      expect(ve.approved_submissions['8658']).to be_instance_of(EtdTransformer::Vireo::Submission)
    end
  end
end
