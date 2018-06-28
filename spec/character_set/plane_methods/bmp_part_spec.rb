shared_examples :character_set_bmp_part do |variant|
  it 'returns the basic monolingual plane part of a character set' do
    expect(variant[97, 98, 99, 70_000, 70_001].bmp_part)
      .to eq(variant[97, 98, 99])
  end
end

describe "CharacterSet#bmp_part" do
  it_behaves_like :character_set_bmp_part, CharacterSet
end

describe "CharacterSet::Pure#bmp_part" do
  it_behaves_like :character_set_bmp_part, CharacterSet::Pure
end
