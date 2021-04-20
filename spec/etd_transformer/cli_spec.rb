# frozen_string_literal: true

RSpec.describe EtdTransformer::Cli do
  let(:cli) { described_class.new }
  let(:input_dir) { "#{$fixture_path}/mock-downloads/German" }
  let(:output_dir) { "#{$fixture_path}/export/German" }
  let(:options) { { input: input_dir, output: output_dir } }

  context 'without arguments' do
    it 'prints a help message' do
      expect { cli.invoke(:process) }.to output(/help/).to_stdout
    end
  end

  context 'with required arguments' do
    it 'has an input directory' do
      expect { cli.invoke(:process, [], options) }.to output(/#{input_dir}/).to_stdout
    end

    it 'has an output directory' do
      expect { cli.invoke(:process, [], options) }.to output(/#{output_dir}/).to_stdout
    end
  end
end
