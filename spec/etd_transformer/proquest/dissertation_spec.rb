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
    let(:author) { "Madalina Vlasceanu" }
    let(:department) { "Psychology" }
    let(:embargo_date) { '2023-05-24' }

    it "has an id" do
      expect(pd.id).to eq "802744"
    end

    it "extracts the author" do
      expect(pd.author).to eq author
    end

    it "extracts the title" do
      expect(pd.title).to eq title
    end

    it "#abstract" do
      expect(pd.abstract).to match(/^Misinformation spread is among the top threats/)
    end

    it "#advisor" do
      expect(pd.advisor).to eq "Alin Coman"
    end

    it "#accept_date" do
      expect(pd.accept_date).to eq "2021-01-01"
    end

    it "#comp_date" do
      expect(pd.comp_date).to eq "2021"
    end

    it "#degree" do
      expect(pd.degree).to eq "Ph.D."
    end

    it "#iso_language" do
      expect(pd.iso_language).to eq "en"
    end

    it "extracts the department" do
      expect(pd.department).to eq department
    end

    it "extracts the embargo date and formats properly" do
      expect(pd.embargo_date).to eq embargo_date
    end

    it 'maps the department to the correct handle' do
      expect(pd.handle).to eq handle
    end

    context "keywords" do
      let(:zipfile) { "#{$fixture_path}/proquest_dissertations/etdadmin_upload_796867.zip" }
      let(:expected_keywords) do
        [
          'Commensurability Oscillations',
          'Fractional Quantum Hall Effect',
          'Gallium Arsenide',
          'Indium Arsenide',
          'Quantum Well',
          'Wigner Crystal'
        ]
      end
      let(:expected_subjects) do
        [
          'Condensed matter physics',
          'Low temperature physics',
          'Materials Science'
        ]
      end
      it "separates keywords" do
        expect(pd.keywords).to eq(expected_keywords)
      end
      it "has subjects" do
        expect(pd.subjects).to eq(expected_subjects)
      end
    end
  end

  context 'dublin_core' do
    it "produces dublin_core" do
      expect(pd.dublin_core).to be_instance_of(Nokogiri::XML::Builder)
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
end
