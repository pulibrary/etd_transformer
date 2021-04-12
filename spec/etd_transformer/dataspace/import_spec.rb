# frozen_string_literal: true

RSpec.describe EtdTransformer::Dataspace::Import do
  let(:di_department_name) { 'German' }
  let(:di) { described_class.new(di_department_name) }
  let(:vireo_export_directory) { "#{$fixture_path}/mock-downloads" }
  let(:dataspace_import_base) { "#{$fixture_path}/mock-exports" }

  around do |example|
    vireo_export_dir_pre_test = ENV['VIREO_EXPORT_DIRECTORY']
    dataspace_import_base_pre_test = ENV['DATASPACE_IMPORT_BASE']
    ENV['VIREO_EXPORT_DIRECTORY'] = vireo_export_directory
    ENV['DATASPACE_IMPORT_BASE'] = dataspace_import_base
    example.run
    ENV['VIREO_EXPORT_DIRECTORY'] = vireo_export_dir_pre_test
    ENV['DATASPACE_IMPORT_BASE'] = dataspace_import_base_pre_test
  end

  it 'has a department' do
    expect(di).to be_instance_of(described_class)
    expect(di.department_name).to eq di_department_name
  end

  it 'has a directory where files are written' do
    expect(di.dataspace_import_directory).to eq "#{dataspace_import_base}/#{di_department_name}"
  end

  context 'filesystem setup' do
    before do
      FileUtils.rm_rf(Dir["#{dataspace_import_base}/*"])
    end
    it 'sets up directory for writing' do
      expect(File.directory?("#{dataspace_import_base}/#{di_department_name}")).to eq false
      di.setup_filesystem
      expect(File.directory?("#{dataspace_import_base}/#{di_department_name}")).to eq true
    end
  end
end
