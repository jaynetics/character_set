shared_examples :character_set_bmp_ratio do |variant|
  it 'returns the ratio of characters in the bmp' do
    expect(variant[97, 98, 99, 70_000, 70_001].bmp_ratio).to eq 0.6
  end
end

describe "CharacterSet#bmp_ratio" do
  it_behaves_like :character_set_bmp_ratio, CharacterSet
end

describe "CharacterSet::Pure#bmp_ratio" do
  it_behaves_like :character_set_bmp_ratio, CharacterSet::Pure
end
