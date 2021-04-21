# frozen_string_literal: true

RSpec.describe EtdTransformer::Transformer do
  let(:input_dir) { "#{$fixture_path}/mock-downloads/German" }
  let(:output_dir) { "#{$fixture_path}/export/German" }
  let(:options) { { input: input_dir, output: output_dir } }
  let(:transformer) { described_class.transform(options) }

  context 'with an input and output' do
    it 'has an input and output' do
      expect(transformer.input).to eq input_dir
      expect(transformer.output).to eq output_dir
    end
    it 'has a vireo export' do
      expect(transformer.vireo_export).to be_instance_of(EtdTransformer::Vireo::Export)
    end
  end
end
