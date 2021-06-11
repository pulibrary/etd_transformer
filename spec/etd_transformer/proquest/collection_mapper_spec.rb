# frozen_string_literal: true

RSpec.describe EtdTransformer::Proquest::CollectionMapper do
  it 'initializes' do
    collection_mapper = EtdTransformer::Proquest::CollectionMapper.new
    expect(collection_mapper).to be_instance_of(EtdTransformer::Proquest::CollectionMapper)
  end
end
