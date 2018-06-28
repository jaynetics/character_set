shared_examples :character_set_astral_ratio do |variant|
  it 'returns the ratio of characters in the bmp' do
    expect(variant[97, 98, 99, 70_000, 70_001].astral_ratio).to eq 0.4
  end
end

describe "CharacterSet#astral_ratio" do
  it_behaves_like :character_set_astral_ratio, CharacterSet
end

describe "CharacterSet::Pure#astral_ratio" do
  it_behaves_like :character_set_astral_ratio, CharacterSet::Pure
end
