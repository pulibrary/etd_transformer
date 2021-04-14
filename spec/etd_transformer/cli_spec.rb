# frozen_string_literal: true

RSpec.describe EtdTransformer::Cli do
  let(:cli) { described_class.new }

  context 'without arguments' do
    it 'prints a help message' do
      expect { cli.invoke(:process) }.to output(/help/).to_stdout
    end
  end

  context 'with a source directory' do
    it 'checks that all expected files are present' do
      input_dir = "#{$fixture_path}/mock-downloads/German"
      expect { cli.invoke(:process, [], { input: input_dir }) }.to output(/#{input_dir}/).to_stdout
    end
  end
end
