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

  context 'initial file setup' do
    let(:unzipped_path) { File.join(input, 'DSpaceSimpleArchive') }

    before do
      FileUtils.rm_rf(unzipped_path) if Dir.exist? unzipped_path
    end
    it 'unzips the file' do
      expect(Dir.exist?(unzipped_path)).to eq false
      ve.unzip_archive
      expect(Dir.exist?(unzipped_path)).to eq true
    end
  end

  context 'submissions' do
    it 'has a hash of approved submissions accessible by id' do
      expect(ve.approved_submissions).to be_instance_of(Hash)
      expect(ve.approved_submissions['8658']).to be_instance_of(EtdTransformer::Vireo::Submission)
    end
  end
end
