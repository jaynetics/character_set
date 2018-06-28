shared_examples :character_set_used_by do |variant|
  it 'returns the CharacterSet used by the given String' do
    expect(variant.used_by('cccaaabbb')).to eq variant[97, 98, 99]
  end
end

describe "CharacterSet::used_by" do
  it_behaves_like :character_set_used_by, CharacterSet
end

describe "CharacterSet::Pure::used_by" do
  it_behaves_like :character_set_used_by, CharacterSet::Pure
end
