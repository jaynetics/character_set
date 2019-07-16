shared_examples :character_set_of_property do |variant|
  it 'returns a new CharacterSet with the codepoints of the given property' do
    expect(variant.of_property('ahex').class).to eq variant
    expect(variant.of_property('ahex').map(&:chr).join)
      .to eq '0123456789ABCDEFabcdef'
  end

  it 'raises for unknown property names' do
    expect { variant.of_property('foobar') }
      .to raise_error(RegexpPropertyValues::Error)
  end
end

describe "CharacterSet::of_property" do
  it_behaves_like :character_set_of_property, CharacterSet
end

describe "CharacterSet::Pure::of_property" do
  it_behaves_like :character_set_of_property, CharacterSet::Pure
end
