# frozen_string_literal: true

RSpec.describe EtdTransformer::Proquest::CollectionMapper do
  let(:department_name) { 'Architecture' }
  let(:collection_handle) { '88435/dsp01f4752g74r' }

  it 'points to an xml file' do
    collection_mapper = EtdTransformer::Proquest::CollectionMapper.new
    expect(collection_mapper).to be_instance_of(EtdTransformer::Proquest::CollectionMapper)
    expect(File.file?(collection_mapper.xml_file_path)).to be true
  end

  it 'generates a hash from the xml file' do
    collection_mapper = EtdTransformer::Proquest::CollectionMapper.new
    expect(collection_mapper.mapper).to be_instance_of(Hash)
    mapper = collection_mapper.mapper
    expect(mapper[department_name]).to eq(collection_handle)
  end
end
