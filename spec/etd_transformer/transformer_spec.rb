# frozen_string_literal: true

require 'pdf-reader'

RSpec.describe EtdTransformer::Transformer do
  let(:input_dir) { "#{$fixture_path}/mock-downloads/#{department_name}" }
  let(:department_name) { 'German' }
  let(:output_dir) { "#{$fixture_path}/exports" }
  let(:embargo_spreadsheet) { "#{$fixture_path}/mock-downloads/embargo_spreadsheet_with_netids.xlsx" }
  let(:collection_handle) { '88435/dsp013n203z151' }
  let(:options) do
    {
      input: input_dir,
      output: output_dir,
      embargo_spreadsheet: embargo_spreadsheet,
      collection_handle: collection_handle
    }
  end
  let(:transformer) { described_class.new(options) }

  before do
    FileUtils.rm_rf(output_dir) if Dir.exist? output_dir
  end

  context 'with an input and output' do
    it 'has an input and output' do
      expect(transformer.input_dir).to eq input_dir
      expect(transformer.output_dir).to eq output_dir
    end
    it 'has a collection handle' do
      expect(transformer.collection_handle).to eq collection_handle
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
    let(:department_name) { 'African American Studies' }
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

    context 'contents' do
      it 'copies the contents file' do
        destination_path = File.join(ds.directory_path, 'contents')
        expect(File.exist?(destination_path)).to eq false
        transformer.copy_contents_file(ds)
        expect(File.exist?(destination_path)).to eq true
      end
      context 'when there are extra files' do
        let(:complex_contents_file) { "#{$fixture_path}/contents_files/complex_contents" }
        it 'generates a list of all the extra files in the contents file' do
          extra_files = transformer.list_extra_files(complex_contents_file)
          expect(extra_files.size).to eq 15
        end
        it 'copies any files referenced in the contents file' do
          destination_path = File.join(ds.directory_path, 'fake_file.docx')
          expect(File.exist?(destination_path)).to eq false
          transformer.copy_contents(vs, ds)
          expect(File.exist?(destination_path)).to eq true
        end
      end
      context 'when there are no extra files' do
        let(:ds) { transformer.dataspace_submissions.last }
        it 'does not attempt to copy' do
          expect { transformer.copy_contents(vs, ds) }.not_to raise_error
        end
      end
    end

    it 'copies the license file' do
      destination_path = File.join(ds.directory_path, 'LICENSE.txt')
      expect(File.exist?(destination_path)).to eq false
      transformer.copy_license_file(ds)
      expect(File.exist?(destination_path)).to eq true
    end
    it 'creates a collection import file' do
      destination_path = File.join(ds.directory_path, 'collections')
      expect(File.exist?(destination_path)).to eq false
      transformer.write_collections_file(ds)
      expect(File.exist?(destination_path)).to eq true
    end
    context 'metadata' do
      let(:department_name) { 'German' }
      it 'generates the metadata_pu' do
        destination_path = File.join(ds.directory_path, 'metadata_pu.xml')
        expect(File.exist?(destination_path)).to eq false
        transformer.generate_metadata_pu(vs, ds)
        expect(File.exist?(destination_path)).to eq true
      end
      it 'copies the dublin core metadata' do
        destination_path = File.join(ds.directory_path, 'dublin_core.xml')
        expect(File.exist?(destination_path)).to eq false
        transformer.generate_dublin_core(vs, ds)
        expect(File.exist?(destination_path)).to eq true
      end
    end
  end

  # The titles as written in the embargo spreadsheet contain extra data that will
  # make them harder to match on. They need cleaning.
  context 'title matching' do
    it 'eliminates capitalization, punctuation, and extra data' do
      original_title = '“THE WAY OUT”_ A Contemporary Portrait of 1.5 and Second Generation Immigrants from New York City’s  - Sanna Lee.xml'
      normalized_title = 'the way out a contemporary portrait of 15 and second generation immigrants from new york citys'
      expect(transformer.normalize_title(original_title)).to eq normalized_title
    end
    it 'determines whether two strings match using Levenshtein distance' do
      title1 = "against the malaise of time embodied fragmentation and the temporalities of the dada creaturely 19191937"
      title2 = "against the malaise of time embodied fragmentation and the temporalities of the dada creaturely"
      expect(transformer.match?(title1, title2)).to eq true
      title2 = "a totally different title"
      expect(transformer.match?(title1, title2)).to eq false
    end
  end

  context 'embargoes' do
    let(:ds) { transformer.dataspace_submissions.first }
    let(:vs) { transformer.vireo_export.approved_submissions[ds.id] }

    it "has an embargo spreadsheet" do
      expect(transformer.embargo_spreadsheet).to eq embargo_spreadsheet
    end
    context 'embargo length' do
      it "matches on both netid and title" do
        expect(transformer.embargo_length(vs.netid, vs.title)).to eq 5
      end
      it "does NOT match if only the netid, but not the title, match" do
        expect(transformer.embargo_length('sofieg', 'this is a fake title')).to eq 0
      end
      # sometimes department admins submit the embargo request
      it "matches if the title matches and the netid is a known admin account" do
        title = 'Metadherin Promotes Triple-Negative Breast Cancer Progression and Metastasis by Inducing Immune Evas - Michelle Anna Rowicki.xml'
        netid = 'mrowicki'
        expect(transformer.embargo_length(netid, title)).to eq 2
      end
    end
  end

  context 'mudd walkin status' do
    let(:ds) { transformer.dataspace_submissions.first }
    let(:vs) { transformer.vireo_export.approved_submissions[ds.id] }
    it "looks up mudd walkin status based on netid and title" do
      expect(transformer.walk_in_access(vs.netid, vs.title)).to eq 'Yes'
    end
  end
end
