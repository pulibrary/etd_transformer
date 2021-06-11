# frozen_string_literal: true

RSpec.describe EtdTransformer::Dataspace::Import do
  let(:output_dir) { "#{$fixture_path}/exports/German" }
  let(:di) { described_class.new(output_dir) }

  it 'has a directory where files are written' do
    expect(di.output_dir).to eq output_dir
  end

  context 'filesystem setup' do
    before do
      FileUtils.rm_rf output_dir
    end
    it 'sets up directory for writing' do
      expect(File.directory?(output_dir)).to eq false
      di.setup_filesystem
      expect(File.directory?(output_dir)).to eq true
    end
  end
end
