# frozen_string_literal: true

RSpec.describe EtdTransformer::Vireo::Submission do
  context 'happy path' do
    let(:input_dir) { "#{$fixture_path}/mock-downloads/German" }
    let(:ve_department_name) { 'German' }
    let(:ve) { EtdTransformer::Vireo::Export.new(input_dir) }
    let(:export_dir) { "#{$fixture_path}/exports" }
    let(:submission) { described_class.new(asset_directory: ve.asset_directory, row: row) }
    let(:row) do
      {
        "Student ID" => "961251996",
        "Student name" => "Cheon, Janice",
        "Language" => "en",
        "Status" => "Approved",
        "Approval date" => "05/18/2020 07:52",
        "Certificate Program" => "Medieval Studies Program",
        "Thesis Type" => "Home Department Thesis",
        "Multi Author" => "no",
        "Last Event Time" => "05/18/2020 07:52",
        "Submission date" => "05/08/2020 17:12",
        "Advisors" => "Fore, Devin",
        "ID" => "8234",
        "Title" => "“Against the Malaise of Time”: Embodied Fragmentation and the Temporalities of the Dada Creaturely, 1919-1937",
        "Student email" => "jcheon@princeton.edu",
        "Primary document" => "http://thesis-central.princeton.edu//submit/review/1584978277IgrBDmmfiXo/8297/CHEON-JANICE-THESIS.pdf",
        "Department" => "German"
      }
    end

    it 'gets data from a row from Excel' do
      expect(submission.row).to be_instance_of(Hash)
      expect(submission.student_id).to eq '961251996'
      expect(submission.student_name).to eq 'Cheon, Janice'
      expect(submission.primary_document).to eq 'http://thesis-central.princeton.edu//submit/review/1584978277IgrBDmmfiXo/8297/CHEON-JANICE-THESIS.pdf'
      expect(submission.id).to eq '8234'
    end

    it 'finds the original pdf document' do
      expect(submission.original_pdf).to eq 'CHEON-JANICE-THESIS.pdf'
    end

    it 'has a Vireo::Export from which to get file locations' do
      expect(submission.asset_directory).to eq ve.asset_directory
    end

    it 'knows what directory its original_pdf should be in' do
      location = "#{ve.asset_directory}/DSpaceSimpleArchive/submission_#{submission.id}"
      expect(submission.source_files_directory).to eq location
    end

    it 'ensures the original pdf document exists' do
      expect(submission.original_pdf_exists?).to eq true
    end

    it 'knows the full path of the original_pdf' do
      full_path = "#{ve.asset_directory}/DSpaceSimpleArchive/submission_8234/CHEON-JANICE-THESIS.pdf"
      expect(submission.original_pdf_full_path).to eq full_path
    end

    it 'knows the full path of the contents file' do
      contents_file = "#{ve.asset_directory}/DSpaceSimpleArchive/submission_8234/contents"
      expect(submission.contents_file).to eq contents_file
    end

    it 'has a netid extrapolated from email address' do
      expect(submission.netid).to eq 'jcheon'
    end

    it 'has a title' do
      expect(submission.title).to eq "“Against the Malaise of Time”: Embodied Fragmentation and the Temporalities of the Dada Creaturely, 1919-1937"
    end

    context 'missing fields come in many flavours' do
      it "handles nil" do
        foo = nil
        expect(submission.missing?(foo)).to eq true
      end
      it "handles empty strings" do
        foo = " "
        expect(submission.missing?(foo)).to eq true
      end
      it "handles an empty float" do
        foo = 0.to_f
        expect(submission.missing?(foo)).to eq true
      end
    end

    context 'missing data in spreadsheet' do
      let(:submission) { described_class.new(asset_directory: ve.asset_directory, row: row) }
      let(:row) do
        {
          "Student ID" => "961251996",
          "Student name" => "Cheon, Janice",
          "Language" => "en",
          "Status" => "Approved",
          "Approval date" => "05/18/2020 07:52",
          "Certificate Program" => "Medieval Studies Program",
          "Thesis Type" => "Home Department Thesis",
          "Multi Author" => "no",
          "Last Event Time" => "05/18/2020 07:52",
          "Submission date" => "05/08/2020 17:12",
          "Advisors" => "Fore, Devin",
          "ID" => "8234",
          "Title" => "“Against the Malaise of Time”: Embodied Fragmentation and the Temporalities of the Dada Creaturely, 1919-1937",
          "Student email" => "jcheon@princeton.edu",
          "Primary document" => "",
          "Department" => "German"
        }
      end
      it "raises an error if a required field is missing" do
        expect { submission }.to raise_exception EtdTransformer::Vireo::IncompleteSpreadsheetError
      end
    end

    context 'dublin core metadata' do
      it 'knows the location of the original dublin_core.xml file' do
        file_path = "#{ve.asset_directory}/DSpaceSimpleArchive/submission_8234/dublin_core.xml"
        expect(submission.dublin_core_file_path).to eq file_path
      end
    end

    context 'metadata_pu fields' do
      it 'has a classyear' do
        expect(submission.classyear).to eq '2020'
      end
      it 'has an authorid' do
        expect(submission.authorid).to eq '961251996'
      end
      context 'department' do
        it 'provides the department if this is a Home Department Thesis' do
          expect(submission.department).to eq 'German'
        end
        context 'vireo munged department names' do
          context 'replaces ampersands and engr' do
            let(:row) do
              {
                "Approval date" => "05/18/2020 07:52",
                "ID" => "fake",
                "Primary document" => "fake",
                "Student email" => "fake@fake.com",
                "Student ID" => "4321",
                "Student name" => "Toast, Jane",
                "Submission date" => "05/08/2020 17:12",
                "Title" => "My Life With Pirates",
                "Status" => "Approved",
                "Thesis Type" => "Home Department Thesis",
                "Department" => "Engr & Food (Fake)"
              }
            end
            it 'adjusts the department name' do
              expect(submission.department).to eq 'Engineering and Food'
            end
          end
          context 'maps vireo-specific departments' do
            let(:row) do
              {
                "Approval date" => "05/18/2020 07:52",
                "ID" => "fake",
                "Primary document" => "fake",
                "Student email" => "fake@fake.com",
                "Student ID" => "4321",
                "Student name" => "Toast, Jane",
                "Submission date" => "05/08/2020 17:12",
                "Title" => "My Life With Pirates",
                "Status" => "Approved",
                "Thesis Type" => "Home Department Thesis",
                "Department" => "Architecture"
              }
            end
            it 'uses department mapper' do
              expect(submission.department).to eq 'Architecture School'
            end
          end
        end
        context 'certificate programs' do
          context 'when there is one certificate program' do
            let(:row) do
              {
                "Approval date" => "05/18/2020 07:52",
                "ID" => "fake",
                "Primary document" => "fake",
                "Student email" => "fake@fake.com",
                "Student ID" => "4321",
                "Submission date" => "05/08/2020 17:12",
                "Title" => "My Life With Pirates",
                "Thesis Type" => "Home Department Thesis",
                "Student name" => "Toast, Jane",
                "Status" => "Approved",
                "Department" => "Architecture",
                "Certificate Program" => "Latin American Studies Program"
              }
            end
            it 'returns an array with a single value' do
              expect(submission.certificate_programs).to eq ["Latin American Studies Program"]
            end
          end
          # See https://github.com/pulibrary/vireo_transformation/issues/16
          xcontext 'when there are multiple certificate programs' do
          end
        end
      end
    end
  end
end
