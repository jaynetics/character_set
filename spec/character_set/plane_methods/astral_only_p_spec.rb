shared_examples :character_set_astral_only_p do |variant|
  it 'returns true for astral-only sets' do
    expect(variant[].astral_only?).to be true
    expect(variant[97].astral_only?).to be false
    expect(variant[97, 0x12345].astral_only?).to be false
    expect(variant[0x10FFFF].astral_only?).to be true
  end
end

describe "CharacterSet#astral_only?" do
  it_behaves_like :character_set_astral_only_p, CharacterSet
end

describe "CharacterSet::Pure#astral_only?" do
  it_behaves_like :character_set_astral_only_p, CharacterSet::Pure
end
