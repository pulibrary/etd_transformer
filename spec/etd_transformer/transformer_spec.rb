# frozen_string_literal: true

require 'pdf-reader'

RSpec.describe EtdTransformer::Transformer do
  let(:input_dir) { "#{$fixture_path}/mock-downloads/#{department_name}" }
  let(:department_name) { 'German' }
  let(:output_dir) { "#{$fixture_path}/exports" }
  let(:options) { { input: input_dir, output: output_dir } }
  let(:transformer) { described_class.new(options) }

  before do
    FileUtils.rm_rf(output_dir) if Dir.exist? output_dir
  end

  context 'with an input and output' do
    it 'has an input and output' do
      expect(transformer.input_dir).to eq input_dir
      expect(transformer.output_dir).to eq output_dir
    end
    it 'has a vireo export' do
      expect(transformer.vireo_export).to be_instance_of(EtdTransformer::Vireo::Export)
    end
    it 'has a dataspace import' do
      expect(transformer.dataspace_import).to be_instance_of(EtdTransformer::Dataspace::Import)
      expect(transformer.dataspace_import.dataspace_import_directory).to eq "#{output_dir}/German"
    end
    it 'creates the output_dir if it does not exist yet' do
      expect(Dir.exist?(output_dir)).to eq false
      transformer
      expect(Dir.exist?(output_dir)).to eq true
    end
  end

  context 'inventory' do
    it 'has a list of dataspace submissions to populate' do
      expect(transformer.dataspace_submissions).to be_instance_of(Array)
      expect(transformer.dataspace_submissions.size).to eq 6
      expect(transformer.dataspace_submissions.first).to be_instance_of(EtdTransformer::Dataspace::Submission)
    end
  end

  context 'transforming a department' do
    let(:expected_submission_directories) do
      [
        File.join(output_dir, department_name, 'submission_8234'),
        File.join(output_dir, department_name, 'submission_8286'),
        File.join(output_dir, department_name, 'submission_8543'),
        File.join(output_dir, department_name, 'submission_8658'),
        File.join(output_dir, department_name, 'submission_8789'),
        File.join(output_dir, department_name, 'submission_8963')
      ]
    end
    it 'makes a directory for every approved submission' do
      expect(Dir.glob("#{transformer.dataspace_import.dataspace_import_directory}/**")).to eq []
      transformer.dataspace_submissions
      dirs_on_disk = Dir.glob("#{transformer.dataspace_import.dataspace_import_directory}/**")
      expect(dirs_on_disk.size).to eq expected_submission_directories.size
      expect(dirs_on_disk & expected_submission_directories == dirs_on_disk).to eq true
    end
  end

  context 'transforming a thesis' do
    let(:unzipped_path) { File.join(transformer.input_dir, 'DSpaceSimpleArchive') }
    let(:ds) { transformer.dataspace_submissions.first }
    let(:vs) { transformer.vireo_export.approved_submissions[ds.id] }

    before do
      FileUtils.rm_rf(unzipped_path) if Dir.exist? unzipped_path
      transformer.vireo_export.unzip_archive
    end
    it 'copies the PDF and adds a cover page' do
      original_number_of_pages = PDF::Reader.new(vs.original_pdf_full_path).page_count
      destination_path = File.join(ds.directory_path, vs.original_pdf)
      expect(File.exist?(destination_path)).to eq false
      transformer.process_pdf(ds)
      expect(File.exist?(destination_path)).to eq true
      post_processing_number_of_pages = PDF::Reader.new(destination_path).page_count
      # page count of the PDF should increase by one (the cover page)
      expect(original_number_of_pages + 1).to eq post_processing_number_of_pages
    end

    it 'copies the license file' do
      destination_path = File.join(ds.directory_path, 'LICENSE.txt')
      expect(File.exist?(destination_path)).to eq false
      transformer.copy_license_file(ds)
      expect(File.exist?(destination_path)).to eq true
    end

    it 'generates the metadata_pu' do
      destination_path = File.join(ds.directory_path, 'metadata_pu.xml')
      expect(File.exist?(destination_path)).to eq false
      transformer.generate_metadata_pu(vs, ds)
      expect(File.exist?(destination_path)).to eq true
    end
  end
end
