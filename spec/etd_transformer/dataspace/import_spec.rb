# frozen_string_literal: true

RSpec.describe EtdTransformer::Dataspace::Import do
  let(:di_department_name) { 'German' }
  let(:input_dir) { "#{$fixture_path}/mock-downloads/German" }
  let(:output_dir) { "#{$fixture_path}/exports" }
  let(:di) { described_class.new(output_dir, di_department_name) }

  it 'has a department' do
    expect(di).to be_instance_of(described_class)
    expect(di.department_name).to eq di_department_name
  end

  it 'has a directory where files are written' do
    expect(di.dataspace_import_directory).to eq "#{output_dir}/#{di_department_name}"
  end

  context 'filesystem setup' do
    before do
      FileUtils.rm_rf(Dir["#{output_dir}/*"])
    end
    it 'sets up directory for writing' do
      expect(File.directory?("#{output_dir}/#{di_department_name}")).to eq false
      di.setup_filesystem
      expect(File.directory?("#{output_dir}/#{di_department_name}")).to eq true
    end
  end
end
