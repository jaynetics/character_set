shared_examples :character_set_count do |variant|
  it 'returns the number of codepoints in the set' do
    expect(variant[97, 98, 0x10000].count).to eq 3
  end

  it 'takes an argument' do
    expect(variant[97, 98, 0x10000].count(98)).to eq 1
  end

  it 'takes a block' do
    expect(variant[97, 98, 0x10000].count(&:even?)).to eq 2
  end
end

describe "CharacterSet#count" do
  it_behaves_like :character_set_count, CharacterSet
end

describe "CharacterSet::Pure#count" do
  it_behaves_like :character_set_count, CharacterSet::Pure
end
