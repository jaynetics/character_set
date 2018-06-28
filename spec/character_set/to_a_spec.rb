shared_examples :character_set_to_a do |variant|
  it 'returns the codepoints as Array' do
    expect(variant[97, 98, 99].to_a).to eq [97, 98, 99]
  end

  it 'returns the codepoints as String if given `true`' do
    expect(variant[97, 98, 99].to_a(true)).to eq ['a', 'b', 'c']
  end
end

describe "CharacterSet#to_a" do
  it_behaves_like :character_set_to_a, CharacterSet
end

describe "CharacterSet::Pure#to_a" do
  it_behaves_like :character_set_to_a, CharacterSet::Pure
end
