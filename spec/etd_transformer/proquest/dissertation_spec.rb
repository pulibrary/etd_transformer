# frozen_string_literal: true

RSpec.describe EtdTransformer::Proquest::Dissertation do
  let(:zipfile) { "#{$fixture_path}/proquest_dissertations/etdadmin_upload_802744.zip" }
  let(:unzipped_dir) { zipfile.gsub('.zip', '') }
  let(:metadata_xml) { File.join(unzipped_dir, 'Vlasceanu_princeton_0181D_13621_DATA.xml') }
  let(:pd) { described_class.new(zipfile) }
  let(:handle) { '88435/dsp019880vr006' }

  before do
    FileUtils.rm_rf(unzipped_dir) if Dir.exist? unzipped_dir
  end

  it 'has an input_dir' do
    expect(pd).to be_instance_of(described_class)
    expect(pd.zipfile).to eq zipfile
  end

  it "unzips the zip file" do
    expect(File.directory?(unzipped_dir)).to eq false
    pd.extract_zip
    expect(pd.dir).to eq unzipped_dir
    expect(File.directory?(unzipped_dir)).to eq true
  end

  it "has a metadata xml file" do
    expect(pd.metadata_xml).to eq metadata_xml
  end

  context 'extracting metadata' do
    let(:title) { "Cognitive Processes Shaping Individual and Collective Belief Systems" }
    let(:department) { "Psychology" }
    let(:embargo_date) { '2023-05-24' }

    it "extracts the title" do
      expect(pd.title).to eq title
    end

    it "extracts the department" do
      expect(pd.department).to eq department
    end

    it "extracts the embargo date and formats properly" do
      expect(pd.embargo_date).to eq embargo_date
    end
  end

  context 'no embargo' do
    let(:zipfile) { "#{$fixture_path}/proquest_dissertations/etdadmin_upload_796867.zip" }
    let(:pd) { described_class.new(zipfile) }

    it 'correctly returns nil when no embargo tag is in the xml' do
      expect(pd.embargo_date).to be_nil
    end

    xit 'no pu metadata file is generated when no embargo is included' do
    end
  end

  it 'maps the department to the correct handle' do
    expect(pd.handle).to eq handle
  end
end
