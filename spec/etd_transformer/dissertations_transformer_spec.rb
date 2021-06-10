# frozen_string_literal: true

require 'pdf-reader'

RSpec.describe EtdTransformer::DissertationsTransformer do
  let(:input_dir) { "#{$fixture_path}/proquest_dissertations" }
  let(:output_dir) { "#{$fixture_path}/proquest_dissertations_export" }
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
    xit 'has a dataspace import' do
      expect(transformer.dataspace_import).to be_instance_of(EtdTransformer::Dataspace::Import)
      expect(transformer.dataspace_import.dataspace_import_directory).to eq "#{output_dir}/German"
    end
    xit 'creates the output_dir if it does not exist yet' do
      expect(Dir.exist?(output_dir)).to eq false
      transformer
      expect(Dir.exist?(output_dir)).to eq true
    end
  end
end
