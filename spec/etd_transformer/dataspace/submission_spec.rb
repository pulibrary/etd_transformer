# frozen_string_literal: true

RSpec.describe EtdTransformer::Dataspace::Submission do
  let(:di_department_name) { 'German' }
  let(:output_dir) { "#{$fixture_path}/exports" }
  let(:di) { EtdTransformer::Dataspace::Import.new(output_dir, di_department_name) }
  let(:ds) { described_class.new(di, '8234') }

  it 'can be instantiated' do
    expect(ds).to be_instance_of(described_class)
  end
  it 'has a Dataspace::Import object' do
    expect(ds.dataspace_import).to be_instance_of(EtdTransformer::Dataspace::Import)
  end
  it 'has an id' do
    expect(ds.id).to eq '8234'
  end
  it 'makes a directory for itself' do
    expect(ds.directory_path).to eq "#{di.output_dir}/#{di_department_name}/submission_#{ds.id}"
  end

  # <dublin_core encoding="utf-8" schema="pu">
  #   <dcvalue element="date" qualifier="classyear">2020</dcvalue>
  #   <dcvalue element="contributor" qualifier="authorid">961152882</dcvalue>
  #   <dcvalue element="pdf" qualifier="coverpage">SeniorThesisCoverPage</dcvalue>
  #   <dcvalue element="department">Religion</dcvalue>
  #   <dcvalue element="certificate">Urban Studies Program</dcvalue>
  # </dublin_core>
  context 'metadata_pu.xml' do
    let(:expected_pu_file) { File.join(ds.directory_path, 'metadata_pu.xml') }
    before do
      FileUtils.rm_rf(expected_pu_file) if File.exist? expected_pu_file
    end
    it 'writes a metadata_pu.xml file' do
      expect(File.exist?(expected_pu_file)).to eq false
      ds.write_metadata_pu
      expect(File.exist?(expected_pu_file)).to eq true
    end
    it 'has a nokogiri XML document to serialize' do
      expect(ds.metadata_pu).to be_instance_of(Nokogiri::XML::Builder)
    end
    it 'writes the department' do
      ds.department = di_department_name
      pu_department = ds.metadata_pu.doc.xpath('//dcvalue[@element="department"]').text
      expect(pu_department).to eq di_department_name
    end
    it 'writes the classyear' do
      classyear = '1999'
      ds.classyear = classyear
      pu_classyear = ds.metadata_pu.doc.xpath('//dcvalue[@element="date"]').text
      expect(pu_classyear).to eq classyear
    end
    it 'writes the authorid' do
      authorid = 'abc123'
      ds.authorid = authorid
      pu_authorid = ds.metadata_pu.doc.xpath('//dcvalue[@element="contributor"]').text
      expect(pu_authorid).to eq authorid
    end
    it 'writes certificate programs' do
      cert_programs = ['Cert 1', 'Cert 2']
      ds.certificate_programs = cert_programs
      cert_programs_in_metadata_pu = ds.metadata_pu.doc.xpath('//dcvalue[@element="certificate"]')
      number_of_cert_programs = cert_programs_in_metadata_pu.count
      expect(number_of_cert_programs).to eq 2
      cert_program_names = cert_programs_in_metadata_pu.map(&:text)
      expect(cert_program_names).to eq cert_programs
    end
    it 'writes the embargo' do
      ds.classyear = 2000
      ds.embargo_length = 5
      expect(ds.embargo_terms).to eq '2005-07-01'
      embargo_terms_in_metadata_pu = ds.metadata_pu.doc.xpath('//dcvalue[@element="embargo.terms"]').text
      expect(embargo_terms_in_metadata_pu).to eq '2005-07-01'
    end
  end
end
