# frozen_string_literal: true

RSpec.describe EtdTransformer::Cli do
  let(:cli) { described_class.new }

  context 'without arguments' do
    it 'prints a help message' do
      expect { cli.invoke(:process_theses) }.to output(/help/).to_stdout
    end
  end

  context 'process theses with required arguments' do
    let(:input_dir) { "#{$fixture_path}/mock-downloads/German" }
    let(:output_dir) { "#{$fixture_path}/cli_invoked" }
    let(:collection_handle) { '88435/dsp013n203z151' }
    let(:embargo_spreadsheet) { "#{$fixture_path}/mock-downloads/embargo_spreadsheet_with_netids.xlsx" }
    let(:options) do
      {
        input: input_dir,
        output: output_dir,
        embargo_spreadsheet: embargo_spreadsheet,
        collection_handle: collection_handle
      }
    end

    before do
      allow(EtdTransformer::SeniorThesesTransformer).to receive(:transform)
    end
    context 'no spaces in path' do
      it 'has an input directory' do
        expect { cli.invoke(:process_theses, [], options) }.to output(/#{input_dir}/).to_stdout
      end

      it 'has an output directory' do
        expect { cli.invoke(:process_theses, [], options) }.to output(/#{output_dir}/).to_stdout
      end

      it 'has an embargo spreadsheet' do
        expect { cli.invoke(:process_theses, [], options) }.to output(/#{embargo_spreadsheet}/).to_stdout
      end

      it 'has a collections handle' do
        expect { cli.invoke(:process_theses, [], options) }.to output(/#{collection_handle}/).to_stdout
      end
    end
    context 'with spaces in path' do
      let(:input_dir) { "#{$fixture_path}/mock-downloads/African\ American\ Studies" }

      it 'has an input directory' do
        expect { cli.invoke(:process_theses, [], options) }.to output(/#{input_dir}/).to_stdout
      end

      it 'has an output directory' do
        expect { cli.invoke(:process_theses, [], options) }.to output(/#{output_dir}/).to_stdout
      end

      it 'has an embargo spreadsheet' do
        expect { cli.invoke(:process_theses, [], options) }.to output(/#{embargo_spreadsheet}/).to_stdout
      end
    end
  end

  context 'process multi-author metadata with required arguments' do
    let(:spreadsheet) { "#{$fixture_path}/multiauthor/ExcelExport.xlsx" }
    let(:directory) { "#{$fixture_path}/multiauthor/" }
    let(:options) do
      {
        spreadsheet: spreadsheet,
        directory: directory
      }
    end

    before do
      allow(EtdTransformer::MultiAuthorAugmentor).to receive(:add_metadata)
    end

    it 'has an input directory' do
      expect { cli.invoke(:multi_author, [], options) }.to output(/#{spreadsheet}/).to_stdout
    end

    it 'has an output directory' do
      expect { cli.invoke(:multi_author, [], options) }.to output(/#{directory}/).to_stdout
    end
  end

  context 'process dissertations with required arguments' do
    let(:input_dir) { "#{$fixture_path}/proquest_dissertations" }
    let(:output_dir) { "#{$fixture_path}/cli_invoked" }
    let(:options) do
      {
        input: input_dir,
        output: output_dir
      }
    end

    it 'has an input directory' do
      expect { cli.invoke(:process_dissertations, [], options) }.to output(/#{input_dir}/).to_stdout
    end

    it 'has an output directory' do
      expect { cli.invoke(:process_dissertations, [], options) }.to output(/#{output_dir}/).to_stdout
    end
  end
end
