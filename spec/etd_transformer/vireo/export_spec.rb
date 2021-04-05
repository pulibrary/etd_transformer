# frozen_string_literal: true

RSpec.describe EtdTransformer::Vireo::Export do
  let(:vireo_export_directory) { "#{$fixture_path}/mock-downloads" }
  let(:dataspace_import_directory) { "#{$fixture_path}/mock-exports" }
  let(:ve_department_name) { 'German' }
  let(:ve) { described_class.new(ve_department_name) }
  let(:ve_asset_directory) { "#{vireo_export_directory}/#{ve_department_name}" }

  around do |example|
    vireo_export_dir_pre_test = ENV['VIREO_EXPORT_DIRECTORY']
    dataspace_import_dir_pre_test = ENV['DATASPACE_IMPORT_DIRECTORY']
    ENV['VIREO_EXPORT_DIRECTORY'] = vireo_export_directory
    ENV['DATASPACE_IMPORT_DIRECTORY'] = dataspace_import_directory
    example.run
    ENV['VIREO_EXPORT_DIRECTORY'] = vireo_export_dir_pre_test
    ENV['DATASPACE_IMPORT_DIRECTORY'] = dataspace_import_dir_pre_test
  end

  it 'has a department' do
    expect(ve).to be_instance_of(described_class)
    expect(ve.department_name).to eq 'German'
  end

  it 'has a vireo_export_directory set via environment variable' do
    expect(ve.vireo_export_directory).to eq vireo_export_directory
  end

  it 'knows what directory its assets are in' do
    expect(ve.asset_directory).to eq ve_asset_directory
  end

  it 'finds and loads the spreadsheet' do
    expect(ve.metadata).to be_instance_of(Creek::Sheet)
    expect(ve.metadata.rows.count).to eq 8
  end

  context 'migrating' do
    before do
      FileUtils.rm_rf(Dir["#{dataspace_import_directory}/*"])
    end
    it 'makes a data space submission folder for each vireo submission' do
      expect(File.directory?("#{dataspace_import_directory}/#{ve_department_name}/Approved")).to eq false
      ve.migrate
      expect(File.directory?("#{dataspace_import_directory}/#{ve_department_name}/Approved")).to eq true
    end
  end
end
