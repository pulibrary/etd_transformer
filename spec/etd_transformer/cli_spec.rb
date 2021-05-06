# frozen_string_literal: true

RSpec.describe EtdTransformer::Cli do
  let(:cli) { described_class.new }
  let(:input_dir) { "#{$fixture_path}/mock-downloads/German" }
  let(:output_dir) { "#{$fixture_path}/cli_invoked" }
  let(:embargo_spreadsheet) { "#{$fixture_path}/mock-downloads/embargo_spreadsheet_with_netids.xlsx" }
  let(:options) { { input: input_dir, output: output_dir, embargo_spreadsheet: embargo_spreadsheet } }

  context 'without arguments' do
    it 'prints a help message' do
      expect { cli.invoke(:process) }.to output(/help/).to_stdout
    end
  end

  context 'with required arguments' do
    before do
      allow(EtdTransformer::Transformer).to receive(:transform)
    end
    context 'no spaces in path' do
      it 'has an input directory' do
        expect { cli.invoke(:process, [], options) }.to output(/#{input_dir}/).to_stdout
      end

      it 'has an output directory' do
        expect { cli.invoke(:process, [], options) }.to output(/#{output_dir}/).to_stdout
      end

      it 'has an embargo spreadsheet' do
        expect { cli.invoke(:process, [], options) }.to output(/#{embargo_spreadsheet}/).to_stdout
      end
    end
    context 'with spaces in path' do
      let(:input_dir) { "#{$fixture_path}/mock-downloads/African\ American\ Studies" }

      it 'has an input directory' do
        expect { cli.invoke(:process, [], options) }.to output(/#{input_dir}/).to_stdout
      end

      it 'has an output directory' do
        expect { cli.invoke(:process, [], options) }.to output(/#{output_dir}/).to_stdout
      end

      it 'has an embargo spreadsheet' do
        expect { cli.invoke(:process, [], options) }.to output(/#{embargo_spreadsheet}/).to_stdout
      end
    end
  end
end
