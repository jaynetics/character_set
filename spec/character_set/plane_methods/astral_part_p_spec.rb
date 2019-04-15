shared_examples :character_set_astral_part_p do |variant|
  it 'returns true iff a part of the character set is astral' do
    expect(variant[97, 98, 99].astral_part?).to be false
    expect(variant[97, 98, 99, 70_000, 70_001].astral_part?).to be true
    expect(variant[70_000, 70_001].astral_part?).to be true
    expect(variant[].astral_part?).to be false
  end
end

describe "CharacterSet#astral_part?" do
  it_behaves_like :character_set_astral_part_p, CharacterSet
end

describe "CharacterSet::Pure#astral_part?" do
  it_behaves_like :character_set_astral_part_p, CharacterSet::Pure
end
