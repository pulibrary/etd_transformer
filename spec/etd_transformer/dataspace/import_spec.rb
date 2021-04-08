# frozen_string_literal: true

RSpec.describe EtdTransformer::Dataspace::Import do
  it 'can be instantiated' do
    import = described_class.new
    expect(import).to be_instance_of(described_class)
  end
end
