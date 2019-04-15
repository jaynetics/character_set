shared_examples :character_set_bmp_part_p do |variant|
  it 'returns true iff a part of the character set is in the bmp' do
    expect(variant[97, 98, 99].bmp_part?).to be true
    expect(variant[97, 98, 99, 70_000, 70_001].bmp_part?).to be true
    expect(variant[70_000, 70_001].bmp_part?).to be false
    expect(variant[].bmp_part?).to be false
  end
end

describe "CharacterSet#bmp_part?" do
  it_behaves_like :character_set_bmp_part_p, CharacterSet
end

describe "CharacterSet::Pure#bmp_part?" do
  it_behaves_like :character_set_bmp_part_p, CharacterSet::Pure
end
