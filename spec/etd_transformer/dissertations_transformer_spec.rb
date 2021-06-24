# frozen_string_literal: true

require 'pdf-reader'

RSpec.describe EtdTransformer::DissertationsTransformer do
  let(:input_dir) { "#{$fixture_path}/proquest_dissertations" }
  let(:output_dir) { "#{$fixture_path}/proquest_dissertations_export" }
  let(:transformed_diss_dir) { File.join(output_dir, 'submission_796867') }
  let(:options) do
    {
      input: input_dir,
      output: output_dir
    }
  end
  let(:transformer) { described_class.new(options) }

  before do
    FileUtils.rm_rf(output_dir) if Dir.exist? output_dir
  end

  context 'with an input and output' do
    it 'has an input and output' do
      expect(transformer.input_dir).to eq input_dir
      expect(transformer.output_dir).to eq output_dir
    end

    it 'creates the output_dir if it does not exist yet' do
      expect(Dir.exist?(output_dir)).to eq false
      transformer
      expect(Dir.exist?(output_dir)).to eq true
    end

    it "makes a proquest dissertation object for each dissertation" do
      expect(transformer.dissertations.size).to eq 2
      expect(Dir.exist?(transformed_diss_dir)).to eq false
      described_class.transform(options)
      expect(Dir.exist?(transformed_diss_dir)).to eq true
    end
  end

  context 'dublin_core.xml' do
    let(:expected_dc_file) { File.join(transformed_diss_dir, 'dublin_core.xml') }
    before do
      FileUtils.rm_rf(expected_dc_file) if File.exist? expected_dc_file
    end
    it 'writes a dublin core metadata file to the expected location' do
      expect(File.exist?(expected_dc_file)).to eq false
      described_class.transform(options)
      expect(File.exist?(expected_dc_file)).to eq true
    end
  end

  context 'metadata_pu.xml' do
    let(:expected_pu_file) { File.join(transformed_diss_dir, 'metadata_pu.xml') }
    before do
      FileUtils.rm_rf(expected_pu_file) if File.exist? expected_pu_file
    end
    it 'writes a metadata_pu.xml file to the expected location' do
      expect(File.exist?(expected_pu_file)).to eq false
      described_class.transform(options)
      expect(File.exist?(expected_pu_file)).to eq true
    end
  end
end
