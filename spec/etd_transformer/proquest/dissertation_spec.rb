# frozen_string_literal: true

RSpec.describe EtdTransformer::Proquest::Dissertation do
  let(:zipfile) { "#{$fixture_path}/proquest_dissertations/etdadmin_upload_790987.zip" }
  let(:unzipped_dir) { zipfile.gsub('.zip', '') }
  let(:pd) { described_class.new(zipfile) }

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
end
