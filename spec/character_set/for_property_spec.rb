shared_examples :character_set_for_property do |variant|
  it 'returns a new CharacterSet with the codepoints of the given property' do
    expect(variant.for_property('ahex').class).to eq variant
    expect(variant.for_property('ahex').map(&:chr).join)
      .to eq '0123456789ABCDEFabcdef'
  end

  it 'raises ArgumentError for unknown property names' do
    expect { variant.for_property('foobar') }.to raise_error(ArgumentError)
  end
end

describe "CharacterSet::for_property" do
  it_behaves_like :character_set_for_property, CharacterSet
end

describe "CharacterSet::Pure::for_property" do
  it_behaves_like :character_set_for_property, CharacterSet::Pure
end
