# frozen_string_literal: true

RSpec.describe EtdTransformer::Vireo::Export do
  let(:vireo_export_directory) { "#{$fixture_path}/mock-downloads" }
  let(:dataspace_import_base) { "#{$fixture_path}/mock-exports" }
  let(:ve_department_name) { 'German' }
  let(:ve) { described_class.new(ve_department_name) }
  let(:ve_asset_directory) { "#{vireo_export_directory}/#{ve_department_name}" }

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

  context 'initial file setup' do
    let(:unzipped_path) { File.join(vireo_export_directory, ve_department_name, 'DSpaceSimpleArchive') }

    before do
      FileUtils.rm_rf(unzipped_path) if Dir.exist? unzipped_path
    end
    it 'unzips the file' do
      expect(Dir.exist?(unzipped_path)).to eq false
      ve.unzip_archive
      expect(Dir.exist?(unzipped_path)).to eq true
    end
  end

  context 'migrating data' do
    before do
      FileUtils.rm_rf(Dir["#{dataspace_import_base}/*"])
    end
    it 'has a corresponding Dataspace::Import object' do
      expect(ve.dataspace_import).to be_instance_of(EtdTransformer::Dataspace::Import)
    end
    it 'makes a data space submission folder for each vireo submission' do
      expect(File.directory?("#{dataspace_import_base}/#{ve_department_name}")).to eq false
      ve.migrate
      expect(File.directory?("#{dataspace_import_base}/#{ve_department_name}")).to eq true
    end
  end
end
