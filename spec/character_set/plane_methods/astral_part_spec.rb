shared_examples :character_set_astral_part do |variant|
  it 'returns the astral planes part of a character set' do
    expect(variant[97, 98, 99, 70_000, 70_001].astral_part)
      .to eq(variant[70_000, 70_001])
  end

  it 'does not create shared mutable state' do
    set1 = variant[96, 97, 70_000]
    set2 = set1.astral_part
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end
end

describe "CharacterSet#astral_part" do
  it_behaves_like :character_set_astral_part, CharacterSet
end

describe "CharacterSet::Pure#astral_part" do
  it_behaves_like :character_set_astral_part, CharacterSet::Pure
end
