shared_examples :character_set_astral_part do |variant|
  it 'returns the astral planes part of a character set' do
    expect(variant[97, 98, 99, 70_000, 70_001].astral_part)
      .to eq(variant[70_000, 70_001])
  end
end

describe "CharacterSet#astral_part" do
  it_behaves_like :character_set_astral_part, CharacterSet
end

describe "CharacterSet::Pure#astral_part" do
  it_behaves_like :character_set_astral_part, CharacterSet::Pure
end
