# frozen_string_literal: true

RSpec.describe EtdTransformer::Proquest::CollectionMapper do
  let(:department_name) { 'Architecture' }

  it 'has a department and points to an xml file' do
    collection_mapper = EtdTransformer::Proquest::CollectionMapper.new(:department_name)
    expect(collection_mapper).to be_instance_of(EtdTransformer::Proquest::CollectionMapper)
    expect(collection_mapper.department_name).to eq(:department_name)
    expect(File.file? collection_mapper.xml_file_path).to be true
  end
end
